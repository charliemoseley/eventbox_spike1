class EventBoxWeb
  # Better Errors
  configure :development do
    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path("..", __FILE__)
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
  end
end