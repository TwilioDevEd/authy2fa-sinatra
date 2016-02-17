require 'sinatra/base'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module TwoFactorAuth
  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/' do
      '2 Factor Auth'
    end
  end
end
