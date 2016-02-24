module UserAuthenticator
  def self.authenticate(password_hash, password_salt, plain_password)
    password_hash == BCrypt::Engine.hash_secret(plain_password, password_hash)
  end
end
