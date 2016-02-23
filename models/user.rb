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
  property :authy_id, String
  property :authy_status, String
end
