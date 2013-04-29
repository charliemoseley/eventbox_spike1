source 'https://rubygems.org'
ruby '1.9.3', engine: 'rbx', engine_version: '2.0.0.rc1'

# Architectural
gem 'foreman'
gem 'puma', '~> 2.0.0.b7'

# Sinatra App
gem 'sinatra'
gem 'pg'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'rack-flash3'
gem 'rack_csrf'

# Asset Pipeline
gem 'sprockets'
gem 'coffee-script'
gem 'sprockets-sass'
gem 'sprockets-helpers'
gem 'sass', '~> 3.3.0.alpha.134'

# Workers
gem 'sidekiq'
gem 'slim'

# For Google Library
gem 'typhoeus'
gem 'json'
gem 'hashie'

# Development Tools
gem 'pry' # Left outside the dev block to make Heroku use this as our console.
group :development do
  gem 'shotgun'
end