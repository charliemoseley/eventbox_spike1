require_relative 'gconnect'

module GCalendar
  class Calendar
    def self.all(access_token, refresh_token)
      connection = GConnect::Connection.new
      connection.api "https://www.googleapis.com/calendar/v3/users/me/calendarList", 
        :get, 
        access_token: access_token,
        refresh_token: refresh_token
    end
  end
end