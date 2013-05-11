module Worker
  module Gcal
    class SubscriptionEvent
      include Sidekiq::Worker
      sidekiq_options backtrace: true, retry: 3
      
      def perform(subscription_id, queued_time)
        subscription = Subscription.find subscription_id
        event        = subscription.subscribable
        account      = subscription.account
        calendar     = Calendar.find_by_provider_calendar_uid subscription.target_info["calendar_uid"]
        puts "*" * 88
        puts event.inspect
        puts "*" * 88
        adapter      = Adapter::Event.from_meetup(event.id)

        if subscription.target_info["event_uid"].nil?
          gcal_event = GCalendar::Event.new \
                         user_uid:      account.provider_uid,
                         access_token:  account.token,
                         refresh_token: account.refresh_token
          gcal_event.calendar_id = calendar.provider_calendar_uid
        else
          gcal_event = GCalendar::Event.find \
                         calendar.provider_calendar_uid,
                         subscription.target_info["event_uid"],
                         user_uid:      account.provider_uid,
                         access_token:  account.token,
                         refresh_token: account.refresh_token

        end
        gcal_event.summary     = adapter.title
        gcal_event.description = adapter.detailed_description
        gcal_event.location    = adapter.address
        gcal_event.start       = adapter.start_time
        gcal_event.end         = adapter.end_time
        gcal_event.save

        subscription.target_info["event_uid"]  = gcal_event.id
        subscription.target_info["event_etag"] = gcal_event.etag
        subscription.target_info_will_change!
        subscription.save
      end
    end
  end
end