require 'rubygems'
require 'bundler'

Bundler.require

require './eventbox_web'
require 'sidekiq/web'

if ENV['RACK_ENV'] == 'production'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_WEB_USER'] && password == ENV['SIDEKIQ_WEB_PASSWORD']
  end
end

run Rack::URLMap.new('/' => EventBoxWeb, '/sidekiq' => Sidekiq::Web)