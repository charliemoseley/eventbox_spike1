require 'sinatra/base'
require 'sinatra/activerecord'
require 'better_errors'
require 'omniauth'
require 'rack-flash'
require 'sinatra/assetpack'

require_relative '../models/boot'
require_relative '../workers/boot'
require_relative '../lib/echidna/echidna'
require_relative '../lib/gcalendar/gcalendar'

class EventBoxWeb < Sinatra::Base
  require_relative 'config'
  
  helpers do
    def current_user
      @current_user ||= User.find session[:user_id] if session[:user_id]
    end
  end
  
  before do
    pass if %w[auth error logout message].include? request.path_info.split('/')[1]
    pass if request.path_info == '/'
    
    unless current_user
      flash[:error] = "You need to be logged in to access this page."
      redirect '/'
    end
  end
  
  get '/' do
    erb :'pages/index'
  end
  
  get '/auth/google_oauth2/callback' do
    user = User.login request.env["omniauth.auth"]
    
    redirect '/error' if user.nil?
    
    # Shoot of the worker to check/create our calendar on login
    account = user.accounts.select{ |a| a.provider = "google_oauth2" }.first
    Worker::GCal::CreateUpcomingCalendar.perform_async(account.id)

    session[:user_id] = user.id
    redirect '/dashboard'
  end
  
  get '/auth/meetup/callback' do
    account = current_user.add_or_update_account request.env["omniauth.auth"]
    redirect '/dashboard'
  end
  
  get '/dashboard' do
    erb :'pages/dashboard'
  end

  get '/test' do
  end
  
  get '/message' do
    Worker::Message::Test.perform_async("Hi Sidekiq")
  end
  
  get '/error' do
    'Uh oh! Something went wrong.'
  end
  
  get '/logout' do
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect '/'
  end
end