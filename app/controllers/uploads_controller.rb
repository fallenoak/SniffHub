require 'fileutils'

class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i(authorize complete)

  # Handle authorize webhook from Lifter.
  def authorize
    user = User.where(uploader_token: params[:uploader_token]).first!

    render(status: 200, json: {}, layout: false)
  end

  # Handle complete webhook from Lifter.
  def complete
    user = User.where(uploader_token: params[:uploader_token]).first!

    upload = user.uploads.new
    upload.file_digest = params[:upload][:file_hash]

    current_path = params[:upload][:file_path]
    target_path = upload.full_path

    # Ensure directory tree exists.
    target_dir = target_path.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(target_dir)

    # Move the completed upload to appropriate uploads directory.
    FileUtils.mv(current_path, target_path)

    upload.original_file_name = params[:upload][:file_name]
    upload.file_name = upload.full_path.split('/').last
    upload.file_path = upload.full_path
    upload.file_size = File.size(upload.full_path)

    begin
      upload.save!
    rescue => e
      # Database save failed, so return file to original path.
      FileUtils.mv(target_path, current_path)
    end

    # Kick off async processing job.
    UploadProcessingWorker.perform_async(upload.id)

    render(status: 200, json: {}, layout: false)
  end
end
