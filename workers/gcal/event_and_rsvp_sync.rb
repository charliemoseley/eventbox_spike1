# 1) Take a user's local events, then split them out to attending and upcomming

# 2) Check the event_rsvp if it has a calendar_event_id associated with it.
# -- if it doesnt
#   Create a calendar entry

# -- otherwise
#   Check if the calendar exists on both the primary and upcoming calendars.

#   If the calendar exists on the appropriate calendar, leave it be.
#   If the calendar has switched to a different calendar, update the status of the event and inform the event provider.
#   If the calendar doesn't exist on either calendaar, recreate it (and update
#   the calendar_event_id)

module Worker
  module GCal
    class CreateUpcomingCalendar
      include Sidekiq::Worker

      def perform(user_id)
        rsvps   = EventRsvp.includes(:event).find_by_user_id(user_id)
        user    = User.fetch(:accounts).find(user_id)
        account = user.accounts.select{|a| a.provider == "google_oauth2"}.first

        rsvp.each do |rsvp|
          if rsvp.calendar_event_id
            # There is an event supposedly already created for this
            calendar = Calendar.get_calendar_for_event(rsvp.event, rsvp.user)
            event = GCalendar::Event.find \
              calendar.id,
              rsvp.calendar_event_id,
              user_uid: account.uid,
              access_token: account.access_token,
              refresh_token: access_token.refresh_token

            # We found the event; we don't need to update it.
            return true unless event.nil?

            # Now we have to figure out if it exists in the alternative location
            opposite_calendar = calendar.opposite
            event = GCalendar::Event.find \
              opposite_calendar.id,
              rsvp.calendar_event_id,
              user_uid: account.uid,
              access_token: account.access_token,
              refresh_token: access_token.refresh_token

            # The event has moved states, so we need to notify the event provider
            unless event.nil?
              # Massive switch statement to deal with the different providers
            else
              # The event isn't found at either location; lets just create it again.

            end
          else
            # We need to create it

          end
        end
      end
    end
  end
end

user_info = event.delete(:self)
          
          event_json   = event.to_json
          event_digest = Digest::SHA1.hexdigest(event_json)

          local_event = Event.select('id, digest').find_by_provider_and_provider_id \
                          "meetup", event.id
          local_event = if local_event.nil?
            Event.create \
              provider: "meetup",
              provider_id: event.id,
              raw: event_json,
              digest: event_digest
          else
            # Update the event if anything has changed.
            if local_event.digest != event_digest
              local_event.raw    = event_json
              local_event.digest = event_digest
              local_event.save
            end
            local_event