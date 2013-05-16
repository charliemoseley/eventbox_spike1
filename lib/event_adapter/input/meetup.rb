module EventAdapter::Input
  module Meetup
    HOUR = 3600

    def self.import(source) # Should be a type of Meetup Event Hashie
      source_json = source.to_json

      event = Event.new
      event.provider     = "meetup"
      event.external_uid = source.id
      event.status       = self.format_status(source)
      event.title        = self.format_title(source, event)
      event.address      = self.format_address(source)
      event.url          = source.event_url
      event.start_time   = Time.at(event.time/1000)
      event.end_time     = self.format_end_time(source)
      event.raw          = source_json
      event.digest       = Digest::SHA1.hexdigest(source_json)
      event.description  = self.format_description(source, event)
      event
    end

    def self.format_title(source, event)
      prefix = event.status == "open" ? "" : "[#{event.status.capitalize}] "
      "#{prefix}#{source.name}"
    end

    def self.format_description(source, event)
      description = Nokogiri::HTML(source.description).text
      
      desc  = "#{event.title}\n"
      desc += "#{event.url}\n\n"
      desc += "#{event.address}\n\n"
      desc += "#{description}\n\n"
      desc += "Event Status: #{event.status.capitalize}\n"
      desc += "Attending: #{source.yes_rsvp_count}"
      desc += " | Max: #{source.rsvp_rules.guest_limit}" unless source.rsvp_rules.guest_limit.nil?
    end

    def self.format_address(source)
      unless source.venue.nil?
        venue = source.venue
        address  = ""
        address += "#{venue.name}, " unless venue.name.nil? || venue.name.empty?
        address += "#{venue.address_1}"
        address += " #{venue.address_2}" unless venue.address_2.nil? || venue.address_2.empty?
        address += ", #{venue.city}, #{venue.state}, #{venue[:zip]}"
        address += ", #{venue.country}" unless venue.country.nil? || venue.country.empty?
      else
        address = "Please see description for instructions."
      end
    end

    def self.format_status(source)
      return "closed"   if source.rsvp_rules.closed == 1
      return "waitlist" if source.rsvp_rules.guest_limit >= source.yes_rsvp_count rescue next
      return "open"
    end

    def self.format_end_time(source)
      return Time.at((event.time + event.duration)/1000) if event.duration?
      # If no duration is set, meetup suggest we assume three hours.
      return start_time + (HOUR * 3)
    end
  end
end