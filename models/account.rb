class Account < ActiveRecord::Base
  belongs_to :user
    
  def self.create_or_update(omniauth)
    account = Account.find_by_provider_and_uid(omniauth.provider, omniauth.uid) ||
              Account.new
    account.provider      = omniauth.provider
    account.uid           = omniauth.uid
    account.name          = omniauth.info.name          rescue nil
    account.first_name    = omniauth.info.first_name    rescue nil
    account.last_name     = omniauth.info.last_name     rescue nil
    account.email         = omniauth.info.email
    account.image         = omniauth.info.image         rescue nil
    account.token         = omniauth.credentials.token
    account.refresh_token = omniauth.credentials.refresh_token rescue nil
    account.expires_at    = omniauth.credentials.expires_at    rescue nil
    account.expires       = omniauth.credentials.expires       rescue nil
    account.raw           = omniauth.to_json
    account.save
    
    return account
  end
end