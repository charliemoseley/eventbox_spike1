class Event < ActiveRecord::Base
  has_many :event_rsvps
  has_many :users, through: :event_rsvps
end