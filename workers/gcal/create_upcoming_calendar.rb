# This worker checks whether or not EventBox's upcoming calendar exists or
# not and appriopately handles the situation.

class Workers
  class GCal
    class CreateUpcomingCalendar
      def perform(account_id)
        account = Account.includes(:user).find(account_id)

        # We don't have a calendar for this user
        if account.calendars.empty?
          external_calendar = create_external_calendar account
          create_internal_calendar account, external_calendar
          return true
        end

        # We do have a calendar on our internal record
        internal_calendar = account.calendars.select{ |c| c.provider == "google" }.first
        external_calendar = find_external_calendar account, internal_calendar.calendar_id

        # Something went wrong
        if external_calendar.kind_of? Echidna::Error
          if external_calendar.body.error.code == 404
            # The calendar just couldn't be found, so let's recreate it.
            external_calendar = create_external_calendar account
            update_internal_calendar account, internal_calendar, external_calendar
            return true
          else
            #  Raise an error so Sidekiq can try again later
            raise external_calendar
          end
        end

        # If it wasn't an error, then we know everything is good.  The user is
        # allowed to customize the calendar as they see fit, we just update the
        # values of our internal version to know any changes they made in case
        # we need to recreate it.

        # WE WILL IMPLEMENT THIS AFTER GETTING ETAGS WORKING AS TO NOT MAKE
        # EXCESSIVE QUERIES
      end

      def create_external_calendar(account)
        calendar = GCalendar::Calendar.new \
                     access_token:  account.token,
                     refresh_token: account.refresh_token,
                     user_uid:      account.uid
        calendar.summary = "Upcoming Events (EventBox.io)"
        calendar.save

        calendar
      end

      def find_external_calendar(account, calendar_id)
        GCalendar::Calendar.find calendar_id,
                                 access_token:  account.token,
                                 refresh_token: account.refresh_token,
                                 user_uid:      account.uid
      end

      def create_internal_calendar(account, external_calendar)
        internal_calendar = Calendar.new
        internal_calendar.user        = account.user
        internal_calendar.account     = account
        internal_calendar.provider    = "google"
        internal_calendar.purpose     = "upcoming"
        internal_calendar.calendar_id = external_calendar.id
        internal_calendar.etag        = external_calendar.etag
        internal_calendar.raw         = external_calendar.to_json
        internal_calendar.save

        internal_calendar
      end

      def update_internal_calendar(account, internal_calendar, external_calendar)
        internal_calendar.user        = account.user
        internal_calendar.account     = account
        internal_calendar.provider    = "google"
        internal_calendar.purpose     = "upcoming"
        internal_calendar.calendar_id = external_calendar.id
        internal_calendar.etag        = external_calendar.etag
        internal_calendar.raw         = external_calendar.to_json
        internal_calendar.save

        internal_calendar
      end
    end
  end
end