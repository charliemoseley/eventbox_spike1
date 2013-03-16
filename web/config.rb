class EventBoxWeb
  # Better Errors
  configure :development do
    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path("..", __FILE__)
  end
  
  # Sessions
  enable :sessions
  set :session_secret, 'asdfewffdvcebjkhbwecowa32u4rbdasjhfb28fgew8agsfd67832gr'
  
  # Omniauth
  use OmniAuth::Builder do
    provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  end
  
  # Configure View Directory
  set :views, Proc.new { File.join(root, 'web/views') }
end