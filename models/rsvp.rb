class Rsvp < ActiveRecord::Base
  has_one  :archive
  has_one  :user, through: :archive
  has_many :subscriptions, as: :subscribable
end