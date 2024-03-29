require 'active_record'
require 'nokogiri'
require 'uri'

# Connect to the postgres db
db = URI.parse ENV['DATABASE_URL']
ActiveRecord::Base.establish_connection \
  adapter:  db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  host:     db.host,
  port:     db.port,
  username: db.user,
  password: db.password,
  database: db.path[1..-1],
  encoding: 'utf8',
  pool:     20,
  reaping_frequency: 10

# Load up all the models
# TODO: Make this scan the models directory and autoload everything.
require_relative '../models/user'
require_relative '../models/account'
require_relative '../models/calendar_account'
require_relative '../models/calendar'
require_relative '../models/event'
require_relative '../models/rsvp'
require_relative '../models/subscription'
require_relative '../models/archive'

# Non AR moderls
require_relative '../models/adapter'