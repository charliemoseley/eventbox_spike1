require "sinatra"
require "sinatra/activerecord"

set :database, 'sqlite3:///db/eventbox.db'

# Load up all the models
require_relative 'user'
require_relative 'account'