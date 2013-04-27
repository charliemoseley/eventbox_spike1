require_relative 'validations'
require_relative 'utilities'

module GCalendar
  class Event < Hashie::Trash
    include GCalendar::Validations
    extend  GCalendar::Utilities
    include GCalendar::Utilities

    # Preserve the Hashie update method
    alias_method :hashie_update, :update
    
    properties = %w(kind etag id status created updated summary description 
                    location creator start end recurrence iCalUID sequence 
                    reminders attendees transparency organizer)
    properties.each { |v| property v }
    
    property :color_id, from: :colorId
    property :html_link, from: :htmlLink
    property :original_start_time, from: :originalStartTime
    property :recurring_event_id, from: :recurringEventId
    property :guests_can_see_other_guests, from: :guestsCanSeeOtherGuests
    property :guests_can_invite_others, from: :guestsCanInviteOthers
    property :private_copy, from: :privateCopy
    # non-google
    property :fetched_at
    property :calendar_id
    
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
      validate_presence_of :calendar_id, :start, :end
      
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.calendar_id}/events"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token
      
      request_options = {
        user_uid:      user_uid,
        access_token:  access_token,
        refresh_token: refresh_token,
        request_body:  camelize_keys(finalize)
      }
      
      response   = @connection.api :post, url, request_options
      return response if response.kind_of? Echidna::Error
      
      self.hashie_update response.body
      return true
    end
    
    def update(options = {})
      # Please note, this can take FOREVER and a day to actually show up in
      # the Google Calendar web interface, probably due to caching.
      validate_presence_of :id, :calendar_id, :start, :end
      
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.calendar_id}/events/#{self.id}"
      user_uid      = options.delete(:user_uid)      || @user_uid
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token
      
      request_options = {
        user_uid:      user_uid,
        access_token:  access_token,
        refresh_token: refresh_token,
        request_body:  camelize_keys(finalize)
      }
      
      response = @connection.api :put, url, request_options
      return response if response.kind_of? Echidna::Error
      
      self.hashie_update response.body
      return true
    end
    
    def self.find(calendar_id, event_id, options = {})
      url = "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events/#{event_id}"
      user_uid      = options.delete(:user_uid)
      access_token  = options.delete(:access_token)
      refresh_token = options.delete(:refresh_token)
      
      request_options = {
        user_uid:       user_uid,
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: camelize_keys(options)
      }
      
      connection = Echidna::Connection.new
      response   = connection.api :get, url, request_options
      return response if response.kind_of? Echidna::Error
      
      # Save the calendar id to the response so it can be rendered into the new
      # object.
      response.body.calendar_id = calendar_id
      Event.new initialize_with: response.body,
                user_uid:        user_uid,
                access_token:    access_token,
                refresh_token:   refresh_token
    end
    
    def self.all(calendar_id, options = {})
      c = GCalendar::Calendar.new
      c.id = calendar_id
      c.all_events(options)
    end

    private
    
    # Runs a bunch of pre save/update process on attributes to make interface
    # nicer.
    def finalize
      unless self.start.kind_of? Hash
        time = self.start
        self.start = { dateTime: convert_time_to_google_datetime(time) }
      end
      unless self.end.kind_of? Hash
        time = self.end
        self.end = { dateTime: convert_time_to_google_datetime(time) }
      end
      self
    end
    
    def convert_time_to_google_datetime(time)
      time.strftime("%Y-%m-%dT%H:%M:%M%:z")
    end
  end
end