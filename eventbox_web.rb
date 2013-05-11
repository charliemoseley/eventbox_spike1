require_relative 'config/models'
require_relative 'config/workers'
require_relative 'config/sinatra'

class EventBoxWeb < Sinatra::Base  
  get '/' do
    erb :'pages/index', layout: :'layout_public'
  end

  get '/login' do
    erb :'pages/login', layout: :'layout_public'
  end

  get '/dashboard' do
    protected_page
    erb :'pages/dashboard', layou: :'layout_dashboard'
  end

  # Authentication Routes
  get '/auth/google_oauth2/callback' do
    user = User.login request.env["omniauth.auth"]
    
    redirect '/error' if user.nil?
    
    # Shoot of the worker to check/create our calendar on login
    account = user.accounts.select{ |a| a.provider == "google_oauth2" }.first
    Worker::Gcal::CreateUpcomingCalendar.perform_async(account.id)

    session[:user_id] = user.id
    redirect '/dashboard'
  end
  
  get '/auth/meetup/callback' do
    account = current_user.add_or_update_account request.env["omniauth.auth"]
    redirect '/dashboard'
  end

  get '/logout' do
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect '/'
  end
  
  # Error Routes
  get '/error' do
    'Uh oh! Something went wrong.'
  end
end