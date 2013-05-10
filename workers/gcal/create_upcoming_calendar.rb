# This worker checks whether or not EventBox's upcoming calendar exists or
# not and appriopately handles the situation.

module Worker
  module Gcal
    class CreateUpcomingCalendar
      include Sidekiq::Worker
      
      def perform(account_id)
        account = Account.find(account_id)
        account = CalendarAccount.new(account)

        ########################################################################
        # Case: No calendars in our internal record
        ########################################################################
        unless account.has_calendars?
          # Create a new internal record for the primary calendar if we don't have it.
          if account.primary_calendar.nil?
            ex_primary_calendar = find_external_primary_calendar account
            in_primary_calendar = create_internal_calendar account,
                                    ex_primary_calendar, "primary"
          end

          # Create a new internal record for the upcoming calendar if we don't have it.
          if account.upcoming_calendar.nil?
            ex_primary_calendar = create_upcoming_calendar account
            in_primary_calendar = create_internal_calendar account,
                                    ex_primary_calendar, "upcoming"
          end

          return true
        end

        ########################################################################
        # Case: Calendars where found in our internal record
        ########################################################################
        in_primary_calendar  = account.primary_calendar
        in_upcoming_calendar = account.upcoming_calendar
        ex_primary_calendar  = find_external_calendar \
                                 account, 
                                 in_primary_calendar.provider_calendar_uid
        ex_upcoming_calendar = find_external_calendar \
                                 account, 
                                 in_upcoming_calendar.provider_calendar_uid

        ########################################################################
        # Case: Calendars where found in our internal record
        ########################################################################

        # TODO: Their primary calendar is gone; we're fucked.

        # The upcoming calendar is missing
        if ex_upcoming_calendar.kind_of? Echidna::Error
          if ex_upcoming_calendar.body.error.code == 404
            # The calendar just couldn't be found, so let's recreate it.
            ex_upcoming_calendar = create_upcoming_calendar account
            update_internal_calendar \
              in_upcoming_calendar.id,
              account, 
              ex_upcoming_calendar,
              "upcoming"
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

      def find_external_primary_calendar(account)
        calendar = GCalendar::Calendar.primary_calendar \
                     access_token:  account.token,
                     refresh_token: account.refresh_token,
                     user_uid:      account.provider_uid
      end

      def create_upcoming_calendar(account)
        calendar = GCalendar::Calendar.new \
                     access_token:  account.token,
                     refresh_token: account.refresh_token,
                     user_uid:      account.provider_uid
        calendar.summary = "Upcoming Events (EventBox.io)"
        calendar.save

        calendar
      end

      def find_external_calendar(account, calendar_id)
        GCalendar::Calendar.find calendar_id,
                                 access_token:  account.token,
                                 refresh_token: account.refresh_token,
                                 user_uid:      account.provider_uid
      end

      def create_internal_calendar(account, external_calendar, purpose)
        internal_calendar                       = Calendar.new
        internal_calendar.account               = account.to_account
        internal_calendar.provider              = "google"
        internal_calendar.provider_calendar_uid = external_calendar.id
        internal_calendar.purpose               = purpose
        internal_calendar.etag                  = external_calendar.etag
        internal_calendar.raw                   = external_calendar.to_json
        internal_calendar.save

        internal_calendar
      end

      def update_internal_calendar(calendar_id, account, external_calendar, purpose)
        internal_calendar = Calendar.find(calendar_id)
        internal_calendar.account               = account.to_account
        internal_calendar.provider              = "google"
        internal_calendar.provider_calendar_uid = external_calendar.id
        internal_calendar.purpose               = purpose
        internal_calendar.etag                  = external_calendar.etag
        internal_calendar.raw                   = external_calendar.to_json
        internal_calendar.save

        internal_calendar
      end
    end
  end
end