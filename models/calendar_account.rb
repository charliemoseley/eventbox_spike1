class CalendarAccount
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def primary_calendar
    @account.calendars.select{ |c| c.purpose == "primary" }.first
  end

  def upcoming_calendar
    @account.calendars.select{ |c| c.purpose == "upcoming" }.first
  end

  def has_calendars?
    primary_calendar && upcoming_calendar
  end

  def to_account
    @account
  end

  def method_missing(method, *args, &block)
    @account.send(method, *args, &block)
  end
end