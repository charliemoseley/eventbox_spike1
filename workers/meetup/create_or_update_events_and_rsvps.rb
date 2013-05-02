# This worker checks whether or not EventBox's upcoming calendar exists or
# not and appriopately handles the situation.

module Worker
  module Meetup
    class CreateOrUpdateEventsAndRsvps
      include Sidekiq::Worker
      
      def perform(account_id)
        account       = Account.find account_id
        access_token  = account.token
        refresh_token = account.refresh_token
        member_id     = account.uid
        user          = account.user

        c = Echidna::Connection.new

        # --- Base Get All User Events All ---
        e = c.api :get, "https://api.meetup.com/2/events", 
                  access_token: access_token, refresh_token: refresh_token,
                  request_params: {
                    member_id: member_id,
                    fields: "self"
                  }

        # Code to create and update our events and rsvp tables
        e.body.results.each do |event|
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
          end

          event_status = user_info.rsvp.response rescue "unspecified"
          rsvp = EventRsvp.find_by_user_id_and_event_id user.id, local_event.id
          rsvp = if rsvp.nil?
            EventRsvp.create user_id: user.id, event_id: local_event.id, 
                             status: event_status, extra: user_info.to_json
          else
            rsvp.status = event_status
            rsvp.extra  = user_info.to_json
            rsvp.save
          end
        end
      end
    end
  end
end