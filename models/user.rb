class User < ActiveRecord::Base
  has_many :accounts
  has_many :subscriptions
  has_many :archives
  has_many :events, through: :subscriptions, source: :subscribable, source_type: "Event"
  has_many :rsvps
  
  def self.login(omniauth)
    ActiveRecord::Base.transaction do
      account = Account.create_or_update omniauth
      user    = User.create_or_update account
    end
  end
  
  def self.create_or_update(account)
    user = account.user || User.new
    user.first_name = account.first_name
    user.last_name  = account.last_name
    user.name       = account.name
    user.email      = account.email
    user.image      = account.image
    user.save
    
    account.user = user
    account.save
    
    return user
  end
  
  def add_or_update_account(omniauth)
    ActiveRecord::Base.transaction do
      account = Account.create_or_update omniauth
      account.user = self
      account.save
    
      return self
    end
  end
end