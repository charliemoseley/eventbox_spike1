# This worker checks whether or not EventBox's upcoming calendar exists or
# not and appriopately handles the situation.

# TODO: This whole worker is specific to GCal, we'll need to abstract that later.

module Worker
  module Meetup
    class CreateOrUpdateEventsAndRsvps
      include Sidekiq::Worker
      
      def perform(account_id)
        account       = Account.find account_id
        access_token  = account.token
        refresh_token = account.refresh_token
        member_id     = account.provider_uid
        user          = account.user

        c = Echidna::Connection.new

        # --- Base Get All User Events All ---
        e = c.api :get, "https://api.meetup.com/2/events", 
                  access_token: access_token, refresh_token: refresh_token,
                  user_uid: account.provider_uid,
                  request_params: {
                    member_id: member_id,
                    fields: "self"
                  }

        # Code to create and update our events and rsvp tables
        e.body.results.each do |event|
          user_info = event.delete(:self)
          
          event_json   = event.to_json
          event_digest = Digest::SHA1.hexdigest(event_json)

          calendar_uid = source_calendar_uid(user, user_info)

          # START EVENT HANDLING
          local_event = Event.select('id, digest').find_by_provider_and_provider_source_uid \
                          "meetup", event.id
          # This is a new event
          if local_event.nil?
            ActiveRecord::Base.transaction do
              # Create the event and subscription
              local_event = Event.create \
                provider: "meetup",
                provider_source_uid: event.id,
                raw: event_json,
                digest: event_digest

              # Meetup stores their dates as milliseconds from epoch
              event_sub = Subscription.create \
                user: user,
                subscribable: local_event,
                provider: "gcal",
                provider_source_uid: calendar_uid,
                account: account,
                last_update: Time.now,
                event_date: Time.at(event.time/1000)
            end
          else
          # The event already exists in our system
            # Update the event if anything has changed.
            if local_event.digest != event_digest
              local_event.raw    = event_json
              local_event.digest = event_digest
              local_event.save

              # Push changes to pubsub
              data = { event_id: local_event.id, timestamp: Time.now }
              $redis.publish "events", data
            end
          end
          # END EVENT HANDLING

          # START RSVP HANDLING
          rsvp_status = user_info.rsvp.response rescue "unspecified"
          local_rsvp = Rsvp.find_by_user_id_and_event_id(user.id, local_event.id)
          # This is a new rsvp
          if local_rsvp.nil?
            ActiveRecord::Base.transaction do
              local_rsvp = Rsvp.create \
                user:   user,
                event:  local_event,
                status: rsvp_status,
                extra:  user_info.to_json

              rsvp_sub = Subscription.create \
                user: user,
                subscribable: local_rsvp,
                provider: "gcal",
                provider_source_uid: calendar_uid,
                account: account,
                last_update: Time.now,
                event_date: Time.at(event.time/1000)
            end
          else
          # The RSVP already exists
            # Update the rsvp if anything has changed.
            if local_rsvp.status != rsvp_status
              local_rsvp.status = rsvp_status
              local_rsvp.extra  = user_info.to_json
              local_rsvp.save

              # Push changes to pubsub
              data = { rsvp_id: local_rsvp.id, timestamp: Time.now }
              $redis.publish "events", data
            end
          end
        end
      end
      
      def source_calendar_uid(user, user_event_info)
        account = user.accounts.select { |a| a.provider == "google_oauth2" }.first
        unless user_event_info.rsvp.nil?
          if user_event_info.rsvp == "yes" || user_event_info.rsvp == "waitlist"
            calendar = account.calendars.select { |c| c.purpose == "primary" }.first
            return calendar.provider_calendar_uid
          end
        end
        calendar = account.calendars.select { |c| c.purpose == "upcoming" }.first
        return calendar.provider_calendar_uid
      end
    end
  end
end