require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/eventbox.db'
)

# Load up all the models
require_relative 'user'
require_relative 'account'