require 'rubygems'
require 'bundler'
Bundler.require

# Setup Sidekiq Web Interface
require 'sidekiq/web'
if ENV['RACK_ENV'] == 'production'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_WEB_USER'] && password == ENV['SIDEKIQ_WEB_PASSWORD']
  end
end

# Setup Sinatra
require './eventbox_web'

# Map out the application paths
run Rack::URLMap.new('/' => EventBoxWeb, '/sidekiq' => Sidekiq::Web)