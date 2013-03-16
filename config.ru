require 'rubygems'
require 'bundler'

Bundler.require

require './eventbox_web'
require 'sidekiq/web'
run Rack::URLMap.new('/' => EventBoxWeb, '/sidekiq' => Sidekiq::Web)