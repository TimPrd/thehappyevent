require 'digest'
class User < ActiveRecord::Base



  attr_accessor :password
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  #Nom
  validates :nom, :presence   =>true,
                   :length     =>{maximum: 50}
  before_save{email.downcase!}
  #Email
  validates :email, :presence  =>true,
                    :length    =>{:maximum => 255},
                    :format    =>{:with    => VALID_EMAIL_REGEX},
                    :uniqueness=>{:case_sensitive => false }
  #Password
  validates :password, :presence     => true,
            :confirmation => true,
            :length       => { :within => 6..40 }



  before_save :encrypt_password

  def has_password?(password_soumis)
    encrypted_password == encrypt(password_soumis)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  private

  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
end


