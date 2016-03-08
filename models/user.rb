require 'data_mapper'

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :email, String
  property :password_salt, Text
  property :password_hash, Text
  property :country_code, String
  property :phone_number, String
  property :authy_id, String, default: ''
  property :authy_status, Enum[:unverified, :onetouch, :sms, :token, :approved, :denied], default: :unverified

  def approved?
    self[:authy_status] == :approved
  end
end
