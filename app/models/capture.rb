class Capture < ActiveRecord::Base
  belongs_to :upload
  belongs_to :user

  def full_path
    raise 'missing digest' if self.file_digest.to_s.empty?
    "#{CAPTURES_DIR}/#{self.file_digest[0, 2]}/#{self.file_digest[2, 2]}/#{self.file_digest}"
  end
end
