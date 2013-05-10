class Event < ActiveRecord::Base
  has_many :archives
  has_many :users, through: :archives
  has_many :subscriptions, as: :subscribable
  has_many :rsvps

  def update_subscribers(time)
    puts "EVENT" + ("*" * 83)
    puts "Trigger local subscriber update for EVENT: #{id} @ #{time}"
    puts "Subscriptions:"
    puts subscriptions.inspect
    puts "*" * 88
    subscriptions.each { |s| s.update(time) }
  end

  def self.update_subscribers(id, time)
    puts "EVENT" + ("*" * 83)
    puts "Trigger global subscriber update for EVENT: #{id} @ #{time}"
    puts "*" * 88
    event = Event.find id
    event.update_subscribers(time)
  end
end