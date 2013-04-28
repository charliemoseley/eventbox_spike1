source 'https://rubygems.org'

group :production do
  ruby '1.9.3', engine: 'rbx', engine_version: '2.0.0.rc1'
end

group :development do
  ruby '2.0.0'
end

# Architectural
gem 'foreman'
gem 'puma', '~> 2.0.0.b7'

# Sinatra App
gem 'sinatra'
gem 'sinatra-assetpack'
gem 'pg'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'omniauth-google-oauth2'
gem 'omniauth-meetup'
gem 'rack-flash3'
gem 'rack_csrf'

# Workers
gem 'sidekiq'
gem 'slim'

# For Google Library
gem 'typhoeus'
gem 'json'
gem 'hashie'

# Development Tools
gem 'pry'

group :development do
  gem 'shotgun'
  gem 'coderay'
end