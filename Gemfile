source 'https://rubygems.org'
ruby '1.9.3', engine: 'rbx', engine_version: '2.0.0.rc1'

# Architectural
gem 'foreman'
gem 'puma', '~> 2.0.0.b7'

# Sinatra App
gem 'sinatra'
gem 'sinatra-assetpack'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'rack-flash3'

# Workers
gem 'sidekiq'
gem 'slim'

# For Google Library
gem 'typhoeus'
gem 'json'
gem 'hashie'

# Development Tools
gem 'pry'

group :production do
  gem 'pg'
end

group :development do
  gem 'coderay'
  gem 'sqlite3'
#  gem 'better_errors'
#  gem 'binding_of_caller'
end