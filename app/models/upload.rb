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
    "#{UPLOADS_DIR}/#{self.file_digest[0, 2]}/#{self.file_digest[2, 2]}/#{self.file_digest}.#{self.file_type}"
  end

  def self.infer_file_type(file_name)
    file_name = file_name.dup

    file_name.downcase!
    file_name.strip!

    if file_name.end_with?('.tar.gz') || file_name.end_with?('.tgz')
      'tgz'
    elsif file_name.end_with?('.gz')
      'gz'
    elsif file_name.end_with?('.pkt')
      'pkt'
    elsif file_name.end_with?('.bin')
      'bin'
    else
      nil
    end
  end
end
