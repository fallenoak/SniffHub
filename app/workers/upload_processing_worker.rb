require 'digest/sha2'

class UploadProcessingWorker
  include Sidekiq::Worker

  GZIP_MAGIC = "\x1f\x8b"               # Opening bytes of valid gzip
  PKT_MAGIC = "PKT"                     # Opening bytes of valid capture
  MINIMUM_CAPTURE_SIZE = 100            # 100 bytes

  def perform(upload_id)
    Upload.transaction do
      upload = Upload.where(id: upload_id).lock('FOR UPDATE').first!
      process(upload)
    end
  end

  private def process(upload)
    case upload.file_type
    when 'tgz'
      handle_tgz_upload(upload)
    when 'gz'
      handle_gz_upload(upload)
    when 'pkt'
      handle_pkt_upload(upload)
    when 'bin'
      handle_bin_upload(upload)
    end

    if upload.captures.count == 0
      upload.unsupported = true
      upload.save!
    end

    upload.processed = true
    upload.save!
  end

  private def handle_tgz_upload(upload)
    archive_dir = "#{WORK_DIR}/archive/#{upload.file_digest}"
    FileUtils.mkdir_p(archive_dir) if !File.exist?(archive_dir)

    untar_cmd = "tar xf #{upload.full_path} -C #{archive_dir}"
    untar_ouput = `#{untar_cmd}`

    handle_extracted_archive(upload, archive_dir)
  end

  private def handle_gz_upload(upload)
    original_file_type = upload.original_file_name.split('.')[-2]
    extracted_path = "#{WORK_DIR}/#{upload.file_digest}.#{original_file_type}"

    gunzip_cmd = "gunzip #{upload.full_path} -c > #{extracted_path}"
    gunzip_output = `#{gunzip_cmd}`

    handle_single_capture(upload, upload.original_file_name, extracted_path)
  end

  private def handle_pkt_upload(upload)
    handle_single_capture(upload, upload.original_file_name, upload.full_path)
  end

  private def handle_bin_upload(upload)
    handle_single_capture(upload, upload.original_file_name, upload.full_path)
  end

  private def handle_extracted_archive(upload, archive_dir)
    archived_file_paths = Dir.glob("#{archive_dir}/**/*")

    # Valid files in archive must:
    # - not be a directory
    # - end with .pkt or .bin
    # - be at least MINIMUM_CAPTURE_SIZE bytes long
    archived_file_paths.map! do |archived_file_path|
      next if !File.file?(archived_file_path)
      next if !(archived_file_path.end_with?('.pkt') || archived_file_path.end_with?('.bin'))
      next if File.size(archived_file_path) < MINIMUM_CAPTURE_SIZE

      archived_file_path
    end

    archived_file_paths.compact!

    if archived_file_paths.length > 0
      upload.archive = true
      upload.save!
    end

    archived_file_paths.each do |archived_file_path|
      original_file_name = archived_file_path.split('/').last
      handle_single_capture(upload, original_file_name, archived_file_path)
    end

    # Remove archive dir.
    FileUtils.remove_dir(archive_dir, true)
  end

  private def handle_single_capture(upload, original_file_name, file_path)
    file_type = file_path.split('.').last.downcase.strip

    # Ensure we have an acceptable file type.
    if Capture.infer_file_type(file_path).nil?
      # TODO logging

      FileUtils.rm(file_path)
      return
    end

    # Ensure we can open with capture parser.
    begin
      parser = WOW::Capture::Parser.new(file_path)
    rescue StandardError => e
      # TODO logging

      FileUtils.rm(file_path)
      return
    end

    file_digest = Digest::SHA2.file(file_path).hexdigest

    capture = Capture.new

    capture.upload = upload
    capture.user = upload.user

    capture.original_file_name = original_file_name
    capture.file_name = file_digest
    capture.file_type = Capture.infer_file_type(file_path)
    capture.file_digest = file_digest
    capture.file_path = capture.full_path
    capture.file_size = File.size(file_path)

    capture.client_build = parser.client_build
    capture.client_locale = parser.client_locale
    capture.format_version = parser.format_version
    capture.capture_time = parser.start_time

    capture.save!

    parser.close

    # Ensure directory tree is established.
    capture_dir = capture.full_path.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(capture_dir)

    # Copy capture to capture directory.
    FileUtils.cp(file_path, capture.full_path)
  end
end
