# Dependancies
require 'sidekiq'
require 'redis'
if ENV['RACK_ENV'] == 'production'
  require 'newrelic_rpm'
end

# Load up the libraries
require_relative '../lib/echidna/echidna'
require_relative '../lib/gcalendar/gcalendar'

# Load up the models
require_relative 'models'

# Load up the workers
# TODO: Make this scan the models directory and autoload everything.
require_relative '../workers/gcal/create_upcoming_calendar'
require_relative '../workers/gcal/subscription_event'
require_relative '../workers/meetup/create_or_update_events_and_rsvps'

# Setup the defaults for our Oauth2 connections
GCalendar::Config.client_id     = ENV['GOOGLE_KEY']
GCalendar::Config.client_secret = ENV['GOOGLE_SECRET']
GCalendar::Config.callback_token_refreshed = ->(provider, user_uid, response) do
  provider = provider + "_oauth2"
  account = Account.find_by_provider_and_provider_uid(provider, user_uid)
  
  puts "*" * 88
  puts "GOOGLE REFRESH"
  puts "provider: #{provider}"
  puts "user_uid: #{user_uid}"
  puts "response:"
  puts response.inspect
  puts "-----"
  puts "account:"
  puts account.inspect
  puts "*" * 88

  account.token = response.access_token
  account.save
end

# Setup the defaults for Echidna to handle Meetup
Echidna::Config.refresh_token_url    = "https://secure.meetup.com/oauth2/access"
Echidna::Config.provider             = "meetup"
Echidna::Config.authorization_bearer = "bearer"
Echidna::Config.client_id            = ENV['MEETUP_KEY']
Echidna::Config.client_secret        = ENV['MEETUP_SECRET']
Echidna::Config.callback_token_refreshed = ->(provider, user_uid, response) do
  account = Account.find_by_provider_and_provider_uid(provider, user_uid)

  puts "*" * 88
  puts "MEETUP REFRESH"
  puts "provider: #{provider}"
  puts "user_uid: #{user_uid}"
  puts "response:"
  puts response.inspect
  puts "-----"
  puts "account:"
  puts account.inspect
  puts "*" * 88
  
  account.token         = response.access_token
  account.refresh_token = response.refresh_token
  account.save
end

# Setup Sidekiq
Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: 'worker' }
end
Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: 'worker' }
end
if ENV['RACK_ENV'] == 'production'
  require 'autoscaler/sidekiq'
  require 'autoscaler/heroku_scaler'
  
  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuScaler.new
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuScaler.new, 60)
    end
  end
end

# Set the base class with connection
module Worker
  $redis = Redis.connect
end