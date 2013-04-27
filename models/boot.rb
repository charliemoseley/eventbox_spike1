require 'active_record'
require 'uri'

unless [:production, :staging].include? ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/eventbox.db'
  )
else # Prod and Staging
  db = URI.parse ENV['DATABASE_URL']

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :port     => db.port,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end

# Load up all the models
require_relative 'user'
require_relative 'account'
require_relative 'calendar'