class Event < ActiveRecord::Base
  has_many :archives
  has_many :users, through: :archives
  has_many :subscriptions, as: :subscribable
  has_many :rsvps

  def update_subscribers(time)
    subscriptions.each { |s| s.update(time) }
  end

  def self.update_subscribers(id, time)
    puts "EVENT" + ("*" * 843)
    puts "Trigger subscribers for EVENT: #{id} @ #{time}"
    puts "*" * 88
  end
end