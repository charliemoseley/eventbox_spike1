class EventBoxWeb
  set :root, File.dirname(__FILE__)
  
  # Assetpack
  register Sinatra::AssetPack
  assets do
    serve '/css', from: 'assets/css'
    css :application, ['/css/vendor/*.css', '/css/app/*.css']
    
    serve '/js', from: 'assets/js'
    js :application, ['/js/vendor/*', '/js/app/*']
    js :modernizr,   ['/js/special/modernizr.js']
    
    serve '/images', from: 'assets/images'
  end
  
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
    
    provider :meetup, ENV['MEETUP_KEY'], ENV['MEETUP_SECRET']
  end
end