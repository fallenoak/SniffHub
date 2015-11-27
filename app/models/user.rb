require 'bcrypt'

class User < ActiveRecord::Base
  # The default cost of 10 is insufficient for currently available hardware.
  BCRYPT_COST = 12

  MINIMUM_PASSWORD_LENGTH = 8

  attr_accessor :password, :password_confirmation, :should_validate_password

  has_many :uploads
  has_many :captures

  validates :email, presence: true, length: { minimum: 3 }
  validates :name, presence: true, length: { minimum: 3, maximum: 12 }
  validate :validate_password

  before_save :hash_password

  def self.authenticate!(email, plain_password)
    user = User.where(email: email).first
    User.new.raise_authentication_error! if user.nil?

    valid_password = User.compare_password(plain_password, user.hashed_password)
    User.new.raise_authentication_error! if !valid_password

    User.upgrade_password!(user, plain_password)

    user
  end

  def self.hash_password(plain_password)
    BCrypt::Password.create(plain_password, cost: BCRYPT_COST)
  end

  def self.compare_password(plain_password, hashed_password)
    BCrypt::Password.new(hashed_password) == plain_password
  end

  # If the stored password cost is less than the currently desired cost, upgrade the stored
  # password.
  def self.upgrade_password!(user, plain_password)
    existing_cost = BCrypt::Password.new(user.hashed_password).cost
    return if existing_cost >= BCRYPT_COST

    Rails.logger.info("Upgrading password hash for user" <<
      "(user id: #{user.id}; existing cost: #{existing_cost}; new cost: #{BCRYPT_COST})")

    upgraded_password = BCrypt::Password.create(plain_password, cost: BCRYPT_COST)

    user.hashed_password = upgraded_password
    user.save!
  end

  def raise_authentication_error!
    self.errors.add(:base, I18n.t('session.authentication_error'))
    raise ActiveRecord::RecordInvalid.new(self)
  end

  private def validate_password
    return if !self.should_validate_password

    if self.password.to_s.length < MINIMUM_PASSWORD_LENGTH
      self.errors.add(:password, I18n.t('registration.password_too_short'))
    end

    if self.password.to_s != self.password_confirmation.to_s
      self.errors.add(:password_confirmation, I18n.t('registration.password_confirmation_mismatch'))
    end
  end

  private def hash_password
    return if self.password.to_s.empty?
    self.hashed_password = User.hash_password(self.password)
  end
end
