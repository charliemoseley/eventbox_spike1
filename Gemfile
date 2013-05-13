source 'https://rubygems.org'
ruby '1.9.3', engine: 'rbx', engine_version: '2.0.0.rc1'

# Architectural
gem 'foreman'
gem 'puma', '~> 2.0.0.b7'
gem 'rake'

# Sinatra App
gem 'sinatra'
gem 'pg'
gem 'activerecord', '~> 4.0.0.rc1'
gem 'sinatra-activerecord'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'rack-flash3'
gem 'rack_csrf'
gem 'redis'
gem 'celluloid'

# Asset Pipeline
gem 'sprockets'
gem 'coffee-script'
gem 'sprockets-sass'
gem 'sprockets-helpers'
gem 'sass', '~> 3.3.0.alpha.134'

# Workers
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'slim', '~> 1.3.8'
gem 'nokogiri'

# For Google Library
gem 'typhoeus'
gem 'json'
gem 'hashie'

group :production do
  gem 'newrelic_rpm'
  gem 'autoscaler'
end

# Development Tools
gem 'pry' # Left outside the dev block to make Heroku use this as our console.
group :development do
  gem 'thor'
end