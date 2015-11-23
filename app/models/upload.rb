class Upload < ActiveRecord::Base
  belongs_to :user
  has_many :captures

  def prologue(length = 1024)
    raise 'cannot retrieve prologue for deleted upload' if deleted?

    file = File.open(full_path, 'rb')
    bytes = file.read(length)
    file.close

    bytes
  end

  def full_path
    raise 'missing digest' if self.file_digest.to_s.empty?
    "#{UPLOADS_DIR}/#{self.file_digest[0, 2]}/#{self.file_digest[2, 2]}/#{self.file_digest}"
  end
end
