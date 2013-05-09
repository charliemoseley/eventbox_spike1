class Rsvp < ActiveRecord::Base
  has_one  :archive
  has_one  :user,  through: :archive
  has_one  :event, through: :archive
  has_many :subscriptions, as: :subscribable

  def self.find_with_user_and_event(user, event)
    Rsvp.joins(:subscriptions).where(
      subscriptions: {
        subscribable_type: "Rsvp",
        provider_source_uid: event.provider_source_uid,
        user: user
      }
    ).first
  end

  def self.update_subscribers(id, time)
    puts "RSVP" + ("*" * 84)
    puts "Trigger subscribers for RSVP: #{id} @ #{time}"
    puts "*" * 88
  end
end