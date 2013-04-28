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
map '/sidekiq' do
  run Sidekiq::Web
end

# Setup Asset Pipeline
require 'sprockets'
map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets/javascripts'
  environment.append_path 'assets/stylesheets'
  run environment
end

# Setup Sinatra
require './eventbox_web'
map '/' do
  run EventBoxWeb
end