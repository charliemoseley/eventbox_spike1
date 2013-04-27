require_relative '../echidna/echidna'
require_relative 'calendar'
require_relative 'event'

module GCalendar
  def self.configure
    yield Config
  end

  module Config
    extend self
    PROVIDER = "google".freeze
    REFRESH_TOKEN_URL = "https://accounts.google.com/o/oauth2/token".freeze

    # Passed to Echidna on intialization
    attr_accessor :client_id, :client_secret
    attr_accessor :callback_request_made, :callback_token_refreshed
    def provider; PROVIDER; end;
    def refresh_token_url; REFRESH_TOKEN_URL; end;
  end

  module Connection
    def self.new(options = {})
      client_id     = options[:client_id]     || GCalendar::Config.client_id
      client_secret = options[:client_secret] || GCalendar::Config.client_secret

      callback_request_made = \
        options[:callback_request_made] ||
        GCalendar::Config.callback_request_made
      callback_token_refreshed = \
        options[:callback_token_refreshed] ||
        GCalendar::Config.callback_token_refreshed

      Echidna::Connection.new provider: GCalendar::Config.provider,
                              refresh_token_url: GCalendar::Config.refresh_token_url,
                              client_id: client_id,
                              client_secret: client_secret,
                              callback_request_made: callback_request_made,
                              callback_token_refreshed: callback_token_refreshed
    end
  end
end