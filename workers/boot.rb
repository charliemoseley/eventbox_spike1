# Dependancies
require 'sidekiq'
require 'redis'

# Load up the models
require_relative '../models/boot'

# Load up the workers
require_relative 'message/test'
require_relative 'gcal/create_upcoming_calendar'

# Set the base class with connection
class Workers
  $redis = Redis.connect
end