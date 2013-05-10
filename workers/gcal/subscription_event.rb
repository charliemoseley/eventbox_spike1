module Worker
  module GCal
    class SubscriptionEvent
      include Sidekiq::Worker
      
      def perform(subscription_id, queued_time)
        subscription = Subscription.find subscription_id
        event        = subscription.event
        account      = subscription.account

        adapter = Adapter::Event.from_meetup(event.id)

        gcal_event = GCalendar::Event.new \
                       user_uid:      account.provider_uid,
                       access_token:  account.token,
                       refresh_token: account.refresh_token
        gcal_event.calendar_id = event.provider_source_uid
        gcal_event.summary     = adapter.detailed_description
        gcal_event.start       = adapter.start_time
        gcal_event.end         = adapter.end_time
        gcal.save
      end
    end
  end
end