require_relative 'config/models'
require_relative 'config/workers'
require_relative 'config/sinatra'

class EventBoxWeb < Sinatra::Base
  before do
    pass if public_pages
    login_required
  end

  def public_pages
    return true if request.path_info == '/'
    p = %w[auth error logout message wait-list]
    p.include? request.path_info.split('/')[1]
  end

  def login_required
    unless current_user
      flash[:error] = "You need to be logged in to access this page."
      redirect '/'
    end
  end
  
  get '/' do
    erb :'pages/index'
  end

  post '/wait-list' do
    puts "Success!"
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
    puts "Hi, test output"
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