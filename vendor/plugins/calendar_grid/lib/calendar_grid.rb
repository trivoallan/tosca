require 'rubygems'
require 'active_support'

module CalendarGrid
  
  # Returns a CalendarGrid::Calendar object. +args+ are the same 
  # as those for CalendarGrid::Builder#initialize
  def self.build(*args, &block)
    Builder.new(*args).build(&block)
  end

  # The result of Builder#build. Holds a list of Year objects and adds
  # a few extra methods.  
  class Calendar
    attr_reader :years
    def initialize(years)
      @years = years
    end
    # Day of first day of first month of first year that is or isn't a proxy
    def first(proxy=false)
      @years.first.months.first.weeks.first.detect { |day| proxy || !day.proxy? } 
    end
    # Day of last day of last month of last week that is or isn't a proxy
    def last(proxy=false)
      @years.last.months.last.weeks.last.reverse.detect { |day| proxy || !day.proxy? }
    end
    # an array of all the Months of all the Years
    def months
      @years.inject([]) { |months, year| months << year.months }.flatten
    end
    # an array of all the Days of all the Months. If proxies=false (the default)
    # strip Days before starting and after ending 
    def days(proxies=false)
      daylist = months.inject([]) { |days, month| days << month.weeks }.flatten.uniq
      unless proxies
        s, e = first.date, last.date
        return daylist.select { |d| d.between?(s, e) }
      end
      daylist
    end
  end
  
  # Build a calendar 
  # builder = CalendarGrid::Builder.new
  # calendar = builder.build
  class Builder
  
    class << self
      attr_accessor :start_wday
    end
    
    # By default start calendars on Sunday
    self.start_wday = 0
  
    # Each builder instance copies the class level start_wday, but you can change it
    attr_accessor :start_wday
    
    # Create a new Builder. Can specify the start date and number of months to
    # build. Defaults to today and 12 months
    def initialize(start=date_today, months=12)
      @starting = Time.local start.year, start.month, 1
      @months = months
      @today = date_today
      @start_wday = self.class.start_wday
    end

    # Execute the builder and return a Calendar object. Use a block that
    # accepts |day| if you want to add a plugin to each Day
    def build(&day_plugin)
      m = months
      m.each do |month|
        first = grid_start(month.date)
        last = increment_month(month.date, 1) - 1.day
        step_days(first, last, 7) do |time|
          month.weeks << days_for_a_week(month.date, time, &day_plugin)
        end
      end 
      years = partition_years m
      Calendar.new years
    end

    private
    
      # given an array of Month objects returns an array of Year objects for each year 
      # with the months for that year assigned to it
      def partition_years(months)
        unique_years = months.collect { |m| m.year }.uniq.sort
        unique_years.collect do |year|
          Year.new Time.local(year), months.select { |m| m.year == year }
        end
      end
      
      # each Month from @starting through @months months
      def months
        (0..(@months - 1)).collect do |cnt|
          Month.new increment_month(@starting, cnt)
        end
      end  
    
      # each day for a week, starting on +day+. If the day is not the same month
      # as +month+, the +proxy+ flag is set on the Day object.
      def days_for_a_week(month, day, &plugin)
        (0..6).collect do |offset|
          # + 1.day is not always accurate. So cheat and then go back to beginning_of_day
          # This is still way faster than using Date
          date = (day + offset.days + 2.hours).at_beginning_of_day
          Day.new date, today?(date), (date.mon != month.mon), &plugin
        end
      end    
      
      # return the date that is the weekday the calendar grid should start
      def grid_start(date)
        offset = @start_wday - date.wday
        offset -= 7 if offset > 0
        date + offset.days
      end
      
      # is the date today?
      def today?(date)
        date == @today
      end
      
      def date_today
        Time.now.beginning_of_day
      end
      
      # increment the month. Falls back to Date if activesupport's months_since is broken
      def increment_month(time, num)
        time.months_since(num) 
      end
    
      # alternative to Date.step because Date is slow
      def step_days(start_time, end_time, days)
        cur = start_time.at_beginning_of_day
        while cur <= end_time
          yield cur
          # BH - + n.days is not always accurate (Daylight Savings Time).  Cheat and go back
          # to beginning_of_day.  Similar to days_for_a_week cheat
          cur = (cur + days.days + 2.hours).at_beginning_of_day
        end
      end

  end

  # Mixin to send missing methods to the internal Time object so you can say 
  # my_month.year instead of my_month.date.year 
  module TimeProxy
    def method_missing(symbol, *args)
      @date.respond_to?(symbol) ? @date.send(symbol, *args) : super
    end
    # let to_s go to the date
    def to_s
      @date.to_s
    end
    # Let comparisons happen on the date
    def eql?(other)
      d = other.kind_of?(Day) ? other.date : date
      @date.eql? d
    end
    # also have to override hash for eql?
    def hash; @date.hash; end
    alias :== :eql?
  end

  # Year has many months
  class Year
    include TimeProxy
    attr_reader :date, :months
    def initialize(date, months=nil)
      @date = Time.local date.year
      @months = months || []
    end
  end

  # Month has many weeks, each week is an array of Day
  class Month
    include TimeProxy
    attr_reader :date, :weeks
    def initialize(date, weeks=nil)
      @date = Time.local date.year, date.month
      @weeks = weeks || []
    end
    # get all the days for the weeks of this month
    def days
      weeks.flatten
    end
  end

  # Day is a single date with some extra knowledge. Also accepts a plugin
  # object for extension. To use it, pass a block that accepts this day
  # and returns some object. The methods of that object will be available
  # directly on the Day
  class Day
    include TimeProxy
    attr_reader :date
    def initialize(date, today=false, proxy=false, &plugin)
      @date, @today, @proxy = date, today, proxy
      @plugin = plugin.call(self) if plugin
    end
    # true if this day isn't really part of the calendar but acts as padding
    def proxy?
      @proxy
    end
    # Is it today?
    def today?
      @today
    end
    # Is it a weekend?
    def weekend?
      [0,6].include? @date.wday
    end
    protected
      def method_missing(symbol, *args)
        if @plugin.respond_to? symbol
          return @plugin.send(symbol, *args)
        end
        super
      end
  end  
  
end