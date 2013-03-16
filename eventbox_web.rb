require 'sinatra/base'
require 'sinatra/activerecord'
require 'better_errors'
require 'omniauth'
require_relative 'models/boot'

class EventBoxWeb < Sinatra::Base
  require_relative 'web/config'
  
  get '/' do
    erb :'pages/index'
  end
  
  get '/auth/google_oauth2/callback' do
    User.login request.env["omniauth.auth"]
    'I logged in!'
  end
end