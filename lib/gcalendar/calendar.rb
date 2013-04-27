require_relative 'validations'
require_relative 'utilities'

module GCalendar
  class Calendar < Hashie::Trash
    include GCalendar::Validations
    extend  GCalendar::Utilities
    include GCalendar::Utilities

    # Preserve the Hashie update method
    alias_method :hashie_update, :update
    
    properties = %w(kind etag id primary summary description location hidden 
                    selected)
    properties.each { |v| property v }
    property :time_zone, from: :timeZone
    property :summary_override, from: :summaryOverride
    property :color_id, from: :colorId
    property :background_color, from: :backgroundColor
    property :foreground_color, from: :foregroundColor
    property :access_role, from: :accessRole
    property :default_reminders, from: :defaultReminders
    # non-google
    property :fetched_at
    
    attr_accessor :user_uid, :access_token, :refresh_token
    attr_reader   :connection
    
    def initialize(options = {})
      @user_uid      = options[:user_uid]
      @access_token  = options[:access_token]
      @refresh_token = options[:refresh_token]

      connection_properties = {
        client_id:                options[:client_id],
        client_secret:            options[:client_secret],
        callback_request_made:    options[:callback_request_made],
        callback_token_refreshed: options[:callback_token_refreshed]
      }
      @connection    = GCalendar::Connection.new connection_properties
      
      super(options[:initialize_with])
      self.fetched_at = Time.now unless hash.nil?
    end
    
    def save(options = {})
      return create(options) if self.id.nil?
      return update(options) if self.id
    end
    
    def create(options = {})
      validate_presence_of :summary
      
      url = "https://www.googleapis.com/calendar/v3/calendars"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token
      
      request_options = {
        user_uid:      user_uid,
        access_token:  access_token,
        refresh_token: refresh_token,
        request_body:  camelize_keys(self)
      }
      
      response   = @connection.api :post, url, request_options
      return response if response.kind_of? Echidna::Error
      
      self.hashie_update response.body
      return true
    end
    
    def update(options = {})
      # Please note, this can take FOREVER and a day to actually show up in
      # the Google Calendar web interface, probably due to caching.
      validate_presence_of :id, :summary
      
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.id}"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token

      request_options = {
        user_uid:      user_uid,
        access_token:  access_token,
        refresh_token: refresh_token,
        request_body:  camelize_keys(self)
      }
      
      response = @connection.api :put, url, request_options
      return response if response.kind_of? Echidna::Error
      
      self.hashie_update response.body
      return true
    end

    def delete(options = {})
      validate_presence_of :id

      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.id}"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token

      request_options = {
        user_uid:      user_uid,
        access_token:  access_token,
        refresh_token: refresh_token
      }
      
      response = @connection.api :delete, url, request_options
      return response if response.kind_of? Echidna::Error
      
      return self
    end

    def all_events(options = {})
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.id}/events"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token
      
      request_options = {
        user_uid:       user_uid,
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: camelize_keys(options)
      }
      
      response = @connection.api :get, url, request_options
      return response if response.kind_of? Echidna::Error
      
      response.body.items.map do |event|
        event.calendar_id = self.id
        Event.new initialize_with: event,
                  user_uid:      user_uid,
                  access_token:  access_token,
                  refresh_token: refresh_token
      end
    end
    
    def self.find(id, options = {})
      raise "Id is requred" if id.nil?
      url = "https://www.googleapis.com/calendar/v3/users/me/calendarList/#{id}"
      user_uid      = options.delete(:user_uid)
      access_token  = options.delete(:access_token)
      refresh_token = options.delete(:refresh_token)
      
      request_options = {
        user_uid:       user_uid,
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: camelize_keys(options)
      }
      
      connection = GCalendar::Connection.new
      response   = connection.api :get, url, request_options
      return response if response.kind_of? Echidna::Error
      
      Calendar.new initialize_with: response.body,
                   user_uid:        user_uid,
                   access_token:    access_token,
                   refresh_token:   refresh_token
    end
    
    def self.all(options = {})
      url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
      user_uid      = options.delete(:user_uid)
      access_token  = options.delete(:access_token)
      refresh_token = options.delete(:refresh_token)
      
      request_options = {
        user_uid:       user_uid,
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: camelize_keys(options)
      }
      
      connection = GCalendar::Connection.new
      response   = connection.api :get, url, request_options
      return response if response.kind_of? Echidna::Error
      
      response.body.items.map do |calendar|
        Calendar.new initialize_with: calendar,
                     user_uid:        user_uid,
                     access_token:    access_token,
                     refresh_token:   refresh_token
      end
    end
    
    def self.primary_calendar(options = {})
      calendars = GCalendar::Calendar.all(options)
      primary   = calendars.select{ |calendar| calendar.primary }
      primary.nil? ? false : primary.first
    end
  end
end