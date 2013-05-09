module Adapter
  class Event
    HOUR = 3600
    attr_accessor :title, :description, :url, :address, :url, :start_time,
      :end_time

    def self.from_meetup(event_id)
      event = Hashie::Mash.new(JSON.parse(::Event.find(event_id).raw))
      adapter = Adapter::Event.new
      adapter.title       = event.name
      adapter.description = Nokogiri::HTML(event.description).text
      adapter.url         = event.event_url

      venue = event.venue
      address  = ""
      address += "#{venue.name}, " unless venue.name.nil? || venue.name.empty?
      address += "#{venue.address_1}"
      address += " #{venue.address_2}" unless venue.address_2.nil? || venue.address_2.empty?
      puts "ZIP CODE!"
      puts venue.zip.inspect
      address += ", #{venue.city}, #{venue.state}, #{venue[:zip]}"
      address += ", #{venue.country}" unless venue.country.nil? || venue.country.empty?
      adapter.address = address

      start_time = Time.at(event.time/1000)
      if event.duration?
        end_time = Time.at(event.duration/1000)
      else
        # If no duration is set, meetup suggest we assume three hours.
        end_time = start_time + (HOUR * 3)
      end
      adapter.start_time = start_time
      adapter.end_time   = end_time

      adapter
    end
  end
end