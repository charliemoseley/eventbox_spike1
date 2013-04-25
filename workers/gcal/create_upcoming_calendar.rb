class Workers
  class GCal
    class CreateUpcomingCalendar
      def perform(account_id)
        account            = Account.find(account_id)
        save_updated_token = ->(response, refresh_token) {
          account = Account.find_by_refresh_token refresh_token
          account.token         = response.access_token
          account.refresh_token = response.refresh_token
          account.save
        }

        calendar = GCalendar::Calendar.new access_token:  account.token,
                                           refresh_token: account.refresh_token
        calendar.summary = "Upcoming Events (Eventbox.io)"
        calendar.save
      end
    end
  end
end