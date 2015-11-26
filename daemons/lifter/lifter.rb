gem 'lifter', '0.1.2'
require 'lifter'

server = Lifter::Server.new do |config|
  # The host and port to listen on for this Lifter server. Typically, Lifter is placed behind by
  # nginx or Apache, although it can directly listen to public network interfaces.
  #
  host '127.0.0.1'
  port 4000

  # A file system path to store in-progress uploads and completed uploads. What happens to uploads
  # after they complete is outside of the scope of Lifter.
  #
  working_dir '../../data/lifter'

  # Define maximum size in bytes of a file upload. Files larger than this will be automatically
  # removed, the connection closed, and no completed webhook will fire.
  #
  max_upload_size 500 * 1024 * 1024

  # Specify desired digest type for file uploads. Passed in uploaded webhook after upload completes.
  # Possible options: md5, sha1, sha256, sha512.
  #
  upload_hash_method :sha256

  # Configure maximum number of bytes to pass along in authorize webhook.
  #
  upload_prologue_size 1024

  # A request to this webhook is made once <upload_prologue_size> bytes have been received by the
  # upload endpoint. The webhook request contains all of the original query params and headers of
  # the upload request, the first <upload_prologue_size> of data, HTTP headers reflecting the
  # request IP, and a query param reflecting file name.
  #
  # In the event the webhook returns a non-200 response, the upload connection is terminated and
  # all uploaded data is removed.
  #
  # In the event the upload is multipart, this endpoint will be called once for each file, as soon
  # as the first <upload_prologue_size> bytes of data is received. Non-200 responses for one part
  # will not remove data from other parts, although the connection will still be terminated.
  #
  authorize_webhook :post, 'http://127.0.0.1:3000/uploads/authorize'

  # A request to this webhook is made once a single file upload completes. In the event the upload
  # is multipart with multiple files, this endpoint will be called once for each file, upon
  # completion of the file.
  #
  # An authorize webhook is always sent prior to sending this webhook.
  #
  completed_webhook :post, 'http://127.0.0.1:3000/uploads/complete'
end

server.start
