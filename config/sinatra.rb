require 'sinatra/base'
require 'sinatra/activerecord'
require 'omniauth'
require 'rack-flash'
require 'rack/csrf'

class EventBoxWeb < Sinatra::Base
  #CSRF
  use Rack::Session::Cookie
  use Rack::Csrf
  
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