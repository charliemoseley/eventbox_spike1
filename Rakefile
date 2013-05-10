# Load bundler, and then load up our environmental variables.
require 'bundler'
Bundler.require
require 'dotenv'
Dotenv.load

#require './eventbox_web'
require 'sinatra/activerecord/rake'
require './config/models'
require './config/workers'
require_relative './tasks/meetup_event_fetch'