# This worker checks whether or not EventBox's upcoming calendar exists or
# not and appriopately handles the situation.

module Worker
  module Gcal
    class CreateUpcomingCalendar
      include Sidekiq::Worker
      sidekiq_options backtrace: true, retry: 3
      
      def perform(account_id)
        account = Account.find(account_id)
        account = CalendarAccount.new(account)

        ########################################################################
        # Case: No calendars in our internal record so we make them.
        ########################################################################
        unless account.has_calendars?
          # Create a new internal record for the primary calendar if we don't have it.
          if account.primary_calendar.nil?
            primary_gcal      = create_google_calendar account, :primary
            primary_local_cal = creater_local_calendar account, :primary, primary_gcal
          end

          # Create a new internal record for the upcoming calendar if we don't have it.
          if account.upcoming_calendar.nil?
            upcoming_gcal      = create_google_calendar account, :upcoming
            upcoming_local_cal = creater_local_calendar account, :upcoming, upcoming_gcal
          end
          return true # We're done, exit out
        end

        ########################################################################
        # Case: Calendars where found in our internal record, so lets just check
        # that there still there and recreate them if not.
        ########################################################################
        primary_local_cal  = account.primary_calendar
        upcoming_local_cal = account.upcoming_calendar

        primary_gcal  = find_google_calendar account, primary_local_cal.provider_calendar_uid
        upcoming_gcal = find_google_calendar account, upcoming_local_cal.provider_calendar_uid

        if primary_gcal.kind_of? Echidna::Error
          if primary_gcal.body.error.code == 404
            primary_gcal      = create_google_calendar account, :primary
            primary_local_cal = update_local_calendar  account, :primary, primary_gcal, primary_local_cal
          else
            # Raise an error so Sidekiq can try again later
            raise primary_gcal
          end
        end

        if upcoming_gcal.kind_of? Echidna::Error
          if upcoming_gcal.body.error.code == 404
            upcoming_gcal      = create_google_calendar account, :upcoming
            upcoming_local_cal = update_local_calendar  account, :upcoming, upcoming_gcal, upcoming_local_cal
          else
            # Raise an error so Sidekiq can try again later
            raise upcoming_gcal
          end
        end

        # FUTURE: If it wasn't an error, then we know everything is good.  The user is
        # allowed to customize the calendar as they see fit, we just update the
        # values of our internal version to know any changes they made in case
        # we need to recreate it.

        # WE WILL IMPLEMENT THIS AFTER GETTING ETAGS WORKING AS TO NOT MAKE
        # EXCESSIVE QUERIES
      end


      private

      def find_google_calendar(account, calendar_id)
        GCalendar::Calendar.find calendar_id,
                                 access_token:  account.token,
                                 refresh_token: account.refresh_token,
                                 user_uid:      account.provider_uid
      end

      def create_google_calendar(account, purpose)
        purpose = purpose.to_sym
        title = "Attending Events (Eventbox.io)" if purpose == :primary
        title = "Upcoming Events (Eventbox.io)"  if purpose == :upcoming
        raise "purpose needs to be either :primary or :upcoming" unless defined?(title)

        calendar = GCalendar::Calendar.new \
                     access_token:  account.token,
                     refresh_token: account.refresh_token,
                     user_uid:      account.provider_uid
        calendar.summary = title
        calendar.save

        calendar
      end

      def creater_local_calendar(account, purpose, google_calendar)
        local_calendar = Calendar.new
        local_calendar_save(account, purpose, google_calendar, local_calendar)
      end

      def update_local_calendar(account, purpose, google_calendar, local_calendar)
        local_calendar_save(account, purpose, google_calendar, local_calendar)
      end

      def local_calendar_save(account, purpose, google_calendar, local_calendar)
        local_calendar.account               = account.to_account
        local_calendar.provider              = "google"
        local_calendar.provider_calendar_uid = google_calendar.id
        local_calendar.purpose               = purpose.to_s
        local_calendar.etag                  = google_calendar.etag
        local_calendar.raw                   = google_calendar.to_json
        local_calendar.save

        local_calendar
      end
    end
  end
end