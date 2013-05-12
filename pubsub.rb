require 'rubygems'
require 'bundler'
Bundler.require
require 'redis'
require 'json'
require 'celluloid'
require 'dotenv'
Dotenv.load
require './config/workers'

class PubSubServer
  include Celluloid

  def initialize
    redis_uri = URI.parse(ENV["REDIS_URL"])
    $redis = Redis.new \
      host: redis_uri.host,
      port: redis_uri.port,
      password: redis_uri.password

    $redis.subscribe('events', 'rsvps') do |on|
      on.message do |channel, msg|
        event_handler(msg)        if channel == "events"
        rsvp_handler(msg)         if channel == "rsvp"
        subscription_handler(msg) if channel == "subscription"
      end
    end
  end

  def event_handler(msg)
    data = JSON.parse(msg)
    Event.update_subscribers data['event_id'], data['timestamp']
  end

  def rsvp_handler(msg)
    data = JSON.parse(msg)
    RSVP.update_subscribers data['rvsp_id'], data['timestamp']
  end

  def subscription_handler(msg)
    data = JSON.parse(msg)
    Subscription.update_individual data['subscription_id'], data['timestamp']
  end
end
PubSubServer.supervise