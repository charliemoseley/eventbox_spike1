require_relative 'gconnect'

module GCalendar
  class Calendar < Hashie::Trash
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
    property :fetched_at # non-google
    
    attr_accessor :access_token, :refresh_token
    attr_reader   :connection
    
    def initialize(hash = nil, options = {})
      @access_token  = options[:access_token]
      @refresh_token = options[:refresh_token]
      @connection    = GConnect::Connection.new
      
      super(hash)
      self.fetched_at = Time.now unless hash.nil?
    end
    
    def all_events(options = {})
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.id}/events"
      access_token  = options.delete(:access_token)  || @access_token
      refresh_token = options.delete(:refresh_token) || @refresh_token
      
      request_options = {
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: options
      }
      
      response   = @connection.api :get, url, request_options
      
      response.body.items.map do |event| 
        Event.new event, access_token:  access_token,
                         refresh_token: refresh_token
      end
    end
    
    def self.find(id, options = {})
      url = "https://www.googleapis.com/calendar/v3/users/me/calendarList/#{id}"
      access_token  = options.delete(:access_token)
      refresh_token = options.delete(:refresh_token)
      
      request_options = {
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: options
      }
      
      connection = GConnect::Connection.new
      response   = connection.api :get, url, request_options
      
      Calendar.new response.body, access_token:  access_token,
                                  refresh_token: refresh_token
    end
    
    def self.all(options = {})
      url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
      access_token  = options.delete(:access_token)
      refresh_token = options.delete(:refresh_token)
      
      request_options = {
        access_token:   access_token,
        refresh_token:  refresh_token,
        request_params: options
      }
      
      connection = GConnect::Connection.new
      response   = connection.api :get, url, request_options
      
      response.body.items.map do |calendar|
        Calendar.new calendar, access_token:  access_token,
                               refresh_token: refresh_token
      end
    end
  end
  
  class Event < Hashie::Trash
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
    property :fetched_at # non-google
    
    attr_accessor :access_token, :refresh_token
    attr_reader   :connection
    
    def initialize(hash = nil, options = {})
      @access_token  = options[:access_token]
      @refresh_token = options[:refresh_token]
      @connection    = GConnect::Connection.new
      
      super(hash)
      self.fetched_at = Time.now unless hash.nil?
    end
  end
end