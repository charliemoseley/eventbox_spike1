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
    
    def initialize(hash = nil, params = {})
      @access_token  = params[:access_token]
      @refresh_token = params[:refresh_token]
      @connection    = GConnect::Connection.new
      hash.fetched_at = Time.now unless hash.nil?
      
      super(hash)
    end
    
    def all_events(params = {})
      url = "https://www.googleapis.com/calendar/v3/calendars/#{self.id}/events"
      result = @connection.api url, :get, access_token: @access_token,
                 refresh_token: @refresh_token
      
      params[:fetched_at] = Time.now
      result.body.items.map { |event| Event.new(event, params) }
    end
    
    def self.find(id, params = {})
      @access_token, @refresh_token = params[:access_token], params[:refresh_token]
      connection = GConnect::Connection.new
      result = connection.api "https://www.googleapis.com/calendar/v3/users/me/calendarList/#{id}", 
        :get, 
        access_token: params[:access_token],
        refresh_token: params[:refresh_token]
      
      params[:fetched_at] = Time.now
      Calendar.new(result.body, params)
    end
    
    def self.all(params = {})
      @access_token, @refresh_token = params[:access_token], params[:refresh_token]
      connection = GConnect::Connection.new
      results = connection.api "https://www.googleapis.com/calendar/v3/users/me/calendarList", 
        :get, 
        access_token: params[:access_token],
        refresh_token: params[:refresh_token]
      
      params[:fetched_at] = Time.now
      results.body.items.map { |calendar| Calendar.new(calendar, params) }
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
    
    def initialize(hash, params = {})
      @access_token  = params[:access_token]
      @refresh_token = params[:refresh_token]
      @connection    = GConnect::Connection.new
      hash.fetched_at = Time.now unless hash.nil?
      
      super(hash)
    end
  end
end