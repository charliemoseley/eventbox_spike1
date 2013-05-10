task :meetup_event_fetch do
  accounts = Account.select(:id).where provider: "meetup"
  accounts.each do |a|
    Worker::Meetup::CreateOrUpdateEventsAndRsvps.perform_async a.id
  end
end