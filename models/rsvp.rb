class Rsvp < ActiveRecord::Base
  has_one  :archive
  belongs_to :user
  belongs_to :event
  has_many :subscriptions, as: :subscribable

  def self.update_subscribers(id, time)
    puts "RSVP" + ("*" * 84)
    puts "Trigger subscribers for RSVP: #{id} @ #{time}"
    puts "*" * 88
  end
end