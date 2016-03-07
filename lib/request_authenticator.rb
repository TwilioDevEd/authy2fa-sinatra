require 'active_support/all'
require 'json'
require 'openssl'
require 'Base64'

module RequestAuthenticator
  def self.authenticate!(request, headers)
    url            = request.url
    request_method = request.request_method
    nonce          = request.env["HTTP_X_AUTHY_SIGNATURE_NONCE"]
    raw_params     = JSON.parse(request.body.read)
    sorted_params  = (Hash[raw_params.sort]).to_query

    data = nonce + "|" + request_method + "|" + url + "|" + sorted_params

    authy_api_key = ENV['AUTHY_API_KEY']
    digest = OpenSSL::HMAC.digest('sha256', authy_api_key, data)
    digest_in_base64 = Base64.encode64(digest)

    theirs = (request.env['HTTP_X_AUTHY_SIGNATURE']).strip
    mine   = digest_in_base64.strip

    unless theirs == mine
      redirect '/login'
    end
  end
end
