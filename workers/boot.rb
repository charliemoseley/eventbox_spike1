# Dependancies
require 'sidekiq'
require 'redis'

# Load up the libraries
require_relative '../lib/echidna/echidna'
require_relative '../lib/gcalendar/gcalendar'

# Load up the models
require_relative '../models/boot'

# Load up the workers
require_relative 'message/test'
require_relative 'gcal/create_upcoming_calendar'

# Setup the defaults for our Oauth2 connections
GCalendar::Config.client_id     = ENV['GOOGLE_KEY']
GCalendar::Config.client_secret = ENV['GOOGLE_SECRET']
GCalendar::Config.callback_token_refreshed = ->(provider, user_uid, response) do
  provider = provider + "_oauth2"
  account = Account.find_by_provider_and_uid(provider, user_uid)
  account.token = response.access_token
  account.save
end

# Set the base class with connection
class Workers
  $redis = Redis.connect
end