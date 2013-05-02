class Event < ActiveRecord::Base
  has_many :archives
  has_many :users, through: :archives
  has_many :subscriptions, as: :subscribable
end