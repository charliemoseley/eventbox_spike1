# Load all the gems
require 'sinatra/base'
require 'sinatra/activerecord'
require 'omniauth'
require 'rack-flash'
require 'rack/csrf'

# Do any sinatra configuration required
class EventBoxWeb < Sinatra::Base
  #CSRF
  use Rack::Session::Cookie
  if ENV['RACK_ENV'] == 'development'
    use Rack::Csrf, raise: true
  else
    use Rack::Csrf
  end
  
  # Sessions
  enable :sessions
  set :session_secret, 'asdfewffdvcebjkhbwecowa32u4rbdasjhfb28fgew8agsfd67832gr'
  use Rack::Flash, sweep: true
  
  # Omniauth
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'],
      scope: 'https://www.google.com/calendar/feeds/,userinfo.email,userinfo.profile',
      access_type: 'offline',
      approval_prompt: 'force'
    
    provider :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']
  end
end

# Load up the helpers for sinatra
# TODO: Make this scan the helpers directory and autoload everything.
require_relative '../helpers/application.rb'
require_relative '../helpers/layout.rb'