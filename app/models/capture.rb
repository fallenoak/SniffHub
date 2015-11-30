class Capture < ActiveRecord::Base
  belongs_to :upload
  belongs_to :user

  def full_path
    raise 'missing digest' if self.file_digest.to_s.empty?
    "#{CAPTURES_DIR}/#{self.file_digest[0, 2]}/#{self.file_digest[2, 2]}/#{self.file_digest}.#{self.file_type}"
  end

  def self.infer_file_type(file_name)
    file_name = file_name.dup

    file_name.downcase!
    file_name.strip!

    if file_name.end_with?('.pkt')
      'pkt'
    elsif file_name.end_with?('.bin')
      'bin'
    else
      nil
    end
  end
end
