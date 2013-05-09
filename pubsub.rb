require 'rubygems'
require 'bundler'
Bundler.require
require 'dotenv'
Dotenv.load

require 'celluloid'
require './config/workers'

class PubSubServer
  include Celluloid

  def initialize
    require 'rubygems'
    require 'redis'
    require 'json'

    $redis = Redis.new(:timeout => 0)

    $redis.subscribe('events', 'rsvps') do |on|
      on.message do |channel, msg|
        # data = JSON.parse(msg)
        # str = "##{channel} - [#{data['user']}]: #{data['msg']} + #{Time.now}"
        # puts str
        # Worker::Message::Test.perform_async(str)
        event_handler(msg) if channel == "events"
        rsvp_handler(msg)  if channel == "rsvp"
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
end
PubSubServer.supervise