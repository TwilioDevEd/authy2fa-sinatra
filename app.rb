require 'sinatra/base'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module TwoFactorAuth
  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/' do
      haml :home
    end

    get '/signup' do
      haml :signup
    end

    post '/signup' do
      name         = [:name]
      email        = params[:email]
      password     = params[:password]
      country_code = params[:country_code]
      phone_number = params[:phone_number]

      haml :signup
    end
  end
end
