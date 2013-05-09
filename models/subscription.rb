class Subscription < ActiveRecord::Base
  belongs_to :subscribable, polymorphic: true
  belongs_to :user
  belongs_to :account
end