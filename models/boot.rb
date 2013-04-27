require 'active_record'
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
  encoding: 'utf8'

# Load up all the models
require_relative 'user'
require_relative 'account'
require_relative 'calendar'