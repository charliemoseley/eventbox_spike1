require_relative 'gconnect'

module GCalendar
  class Calendar < Hashie::Trash
    property :kind
    property :etag
    property :id
    property :primary
    property :summary
    property :description
    property :location
    property :time_zone, from: :timeZone
    property :summary_override, from: :summaryOverride
    property :color_id, from: :colorId
    property :background_color, from: :backgroundColor
    property :foreground_color, from: :foregroundColor
    property :hidden
    property :selected
    property :access_role, from: :accessRole
    property :default_reminders, from: :defaultReminders
    
    def self.find(id, access_token, refresh_token)
      connection = GConnect::Connection.new
      result = connection.api "https://www.googleapis.com/calendar/v3/users/me/calendarList/#{id}", 
        :get, 
        access_token: access_token,
        refresh_token: refresh_token
      
      Calendar.new(result.body)
    end
    
    def self.all(access_token, refresh_token)
      connection = GConnect::Connection.new
      results = connection.api "https://www.googleapis.com/calendar/v3/users/me/calendarList", 
        :get, 
        access_token: access_token,
        refresh_token: refresh_token
      
      results.body.items.map { |calendar| Calendar.new(calendar) }
    end
  end
end

#  "kind": "calendar#calendarListEntry",
#  "etag": etag,
#  "id": string,
#  "summary": string,
#  "description": string,
#  "location": string,
#  "timeZone": string,
#  "summaryOverride": string,
#  "colorId": string,
#  "backgroundColor": string,
#  "foregroundColor": string,
#  "hidden": boolean,
#  "selected": boolean,
#  "accessRole": string,
#  "defaultReminders": [
#    {
#      "method": string,
#      "minutes": integer
#    }