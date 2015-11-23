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
    prologue = upload.prologue(4)

    if prologue[0, 2] == GZIP_MAGIC
      handle_gzip_upload(upload.original_file_name, upload.full_path, upload)
    elsif prologue[0, 3] == PKT_MAGIC
      handle_single_capture(upload.original_file_name, upload.full_path, upload)
    end

    if upload.captures.count == 0
      upload.unsupported = true
      upload.save!
    end

    upload.processed = true
    upload.save!
  end

  private def handle_gzip_upload(original_file_name, file_path, upload)
    extracted_path = "#{WORK_DIR}/#{upload.upload_digest}"
    gunzip_cmd = "gunzip #{upload.full_path} -c > #{extracted_path}"
    gunzip_output = `#{gunzip_cmd}`

    extracted_file = File.open(extracted_path, 'rb')
    extracted_prologue = extracted_file.read(4)
    extracted_file.close

    # Check if sniff. If not, try treat as tar.
    if extracted_prologue[0, 3] == "PKT"
      handle_single_capture(original_file_name, extracted_path, upload)
    else
      handle_tar_upload(extracted_path, upload)
    end

    # Remove work file.
    FileUtils.rm(extracted_path)
  end

  private def handle_tar_upload(file_path, upload)
    FileUtils.mkdir("#{WORK_DIR}/archive") if !File.exist?("#{WORK_DIR}/archive")

    archive_dir = "#{WORK_DIR}/archive/#{upload.upload_digest}"
    FileUtils.mkdir(archive_dir) if !File.exist?(archive_dir)

    untar_cmd = "tar xvf #{file_path} -C #{archive_dir}"
    untar_ouput = `#{untar_cmd}`

    archived_file_paths = Dir.glob("#{archive_dir}/**/*").map do |archived_file_path|
      next if !File.file?(archived_file_path)
      next if File.size(archived_file_path) < MINIMUM_CAPTURE_SIZE
    end

    archived_file_paths.compact!

    if archived_file_paths.length > 0
      upload.archive = true
      upload.save!
    end

    archived_file_paths.each do |archived_file_path|
      original_file_name = archived_file_path.split('/').last
      handle_single_capture(original_file_name, archived_file_path)
    end

    # Remove archive dir.
    FileUtils.remove_dir(archive_dir, true)
  end

  private def handle_single_capture(original_file_name, file_path, upload)
    capture_file = File.open(file_path, 'rb')
    capture_prologue = capture_file.read(4)
    capture_file.close

    # Skip if not a proper packet capture file.
    return if capture_prologue[0, 3] != PKT_MAGIC

    file_digest = Digest::SHA2.file(file_path).hexdigest

    capture = Capture.new
    capture.upload = upload
    capture.user = upload.user
    capture.original_file_name = original_file_name
    capture.file_name = file_digest
    capture.file_digest = file_digest
    capture.file_path = capture.full_path
    capture.file_size = File.size(file_path)
    capture.save!

    # Ensure directory tree is established.
    capture_dir = capture.full_path.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(capture_dir)

    # Copy capture to capture directory.
    FileUtils.cp(file_path, capture.full_path)
  end
end
