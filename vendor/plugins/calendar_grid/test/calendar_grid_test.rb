require 'test/unit'

require File.dirname(__FILE__) + '/../lib/calendar_grid'

module CalendarGrid
  
  # date that tests are based on: Saturday, May 14, 2005
  DATE = Time.local 2005, 5, 14
  
  class BuilderTest < Test::Unit::TestCase
    def setup
      @builder = Builder.new DATE, 12
    end
    def test_class_level_start_wday
      was = Builder.start_wday
      Builder.start_wday = 0
      assert_equal 0, CalendarGrid.build.first(true).wday
      Builder.start_wday = 5
      assert_equal 5, CalendarGrid.build.first(true).wday
      Builder.start_wday = was
    end
    def test_grid_start_1
      @builder.start_wday = 0 # start on Sunday 
      # April first is a Friday. Start should be back 5 days to previous Sunday (March 27)
      d = Time.local 2005, 4, 1 
      start = @builder.send(:grid_start, d)
      expected = Time.local(2005, 3, 27)
      assert_equal expected, start, "#{expected} != #{start}"
    end
    def test_grid_start_2
      @builder.start_wday = 0 # start on Sunday 
      # May first is a Sunday. Start should be same day
      d = Time.local 2005, 5, 1 
      start = @builder.send(:grid_start, d)
      expected = d
      assert_equal expected, start, "#{expected} != #{start}"
    end
    def test_grid_start_3
      @builder.start_wday = 5 # start on Friday
      # May first is a Sunday. Start should be -2 days: 2005, 4, 26
      d = Time.local 2005, 5, 1 
      start = @builder.send(:grid_start, d)
      expected = Time.local(2005, 4, 29)
      assert_equal expected, start, "#{expected} != #{start}"
    end
    def test_grid_start_4
      @builder.start_wday = 3 # start on Wednesday
      # April 1 is Friday, start should be -2 days: March 30
      d = Time.local 2005, 4, 1 
      start = @builder.send(:grid_start, d)
      expected = Time.local(2005, 3, 30)
      assert_equal expected, start, "#{expected} != #{start}"
    end
    def test_days_for_a_week
      m = Time.local 2005, 5
      day = Time.local 2005, 5, 30 # 30, 31 are real, rest are proxy
      days = @builder.send(:days_for_a_week, m, day)
      assert_equal 7, days.size
      days[0..1].each { |d| assert !d.proxy? }
      days[2...days.size].each { |d| assert d.proxy? }
    end
    def test_months
      months = @builder.send(:months)
      assert_equal 12, months.size
      numbers = months.collect { |m| m.mon }
      assert_equal (5..12).to_a + (1..4).to_a, numbers
    end
    def test_partition_years
      m1 = Month.new(DATE)
      m2 = Month.new(DATE.next_year)
      m3 = Month.new(DATE.next_year.next_month)
      years = @builder.send(:partition_years, [m1, m2, m3])
      assert_equal 2, years.size
      assert_equal 1, years[0].months.size
      assert_equal 2, years[1].months.size
    end
    def test_step_days
      first = Time.local(2005,7,6)
      last =  Time.local(2005,7,12)
      expected = [Time.local(2005,7,6), Time.local(2005,7,8), Time.local(2005,7,10), Time.local(2005,7,12)]
      output = []
      @builder.send(:step_days, first, last, 2) do |time|
        output << time
      end
      assert_equal expected, output
    end
    def test_build
      @builder.start_wday = 0 # start on Sunday 
      cal = @builder.build
      assert_kind_of Calendar, cal
      assert_equal 2, cal.years.size
      assert_equal 12, cal.months.size
      assert_equal 371, cal.days(true).size  # 365 days plus 6 days, May 1-6 2006 for proxies
      assert_equal 365, cal.days(false).size  # 365 days
    end
  end
  
  class CalendarTest < Test::Unit::TestCase
    def setup
      m = Month.new DATE, [[Day.new(DATE+1.day), Day.new(DATE+1.day), Day.new(DATE+2.day)]]
      y1 = Year.new DATE, [m]
      
      @year_later = DATE.next_year
      m = Month.new@year_later, [[Day.new(@year_later)]]
      y2 = Year.new @year_later, [m]
      
      years = [y1, y2]
      @cal = Calendar.new years
    end
    def test_first
      assert_equal DATE+1.day, @cal.first.date
    end
    def test_first
      assert_equal @year_later, @cal.last.date
    end
    def test_months
      assert_equal 2, @cal.months.size
    end
    def test_days
      assert_equal 3, @cal.days.size # ensure duplicated days are removed (because some might be proxies)
    end
    def test_active_support_usec_patch
      for i in 1..10
        calendar = CalendarGrid.build(Time.now, 1)
        assert_equal 1, calendar.days.select { |d| d.today? }.length, "Time.beginning_of_day needs to be patched. See active_support_patches."
      end      
    end
  end
  
  class DateProxyTest < Test::Unit::TestCase
    def setup
      # use a Day to test the mixin
      @day = Day.new DATE
    end
    def test_a_method
      assert_equal @day.date.wday, @day.wday
    end
    def test_to_s
      assert_equal @day.date.to_s, @day.to_s
    end
    def test_eql?
      @day2 = Day.new DATE.dup # new Day with copied Date
      assert @day.eql?(@day2)
      assert @day2.eql?(@day)
      assert @day.eql?(@day2.date) # also allow passing a Date
    end
    def test_hash
      assert_equal @day.date.hash, @day.hash
    end
    def test_array_uniq
      @day2 = Day.new DATE.dup # new Day with copied Date
      a = [@day, @day2]
      assert_equal 2, a.size
      assert_equal 1, a.uniq.size
    end
  end
  
  # a really simple plugin
  class DayTestPlugin
    def initialize(day)
      @day = day
    end
    def special?
      true
    end
    def same?(day)
      @day == day
    end
  end
  
  class DayTest < Test::Unit::TestCase
    def setup
      @day = Day.new DATE
    end
    def test_date
      assert_equal DATE, @day.date
    end
    def test_proxy?
      assert !@day.proxy?
      assert Day.new(nil, nil, true).proxy?
    end
    def test_today?
      assert !@day.today?
      assert Day.new(nil, true, nil).today?
    end
    def test_weekend?
      assert @day.weekend?
      assert Day.new(DATE + 1.days).weekend?
      assert !Day.new(DATE + 2.days).weekend?
      assert !Day.new(DATE - 2.days).weekend?
    end
    def test_proxy
      assert_equal "2005-05-14 00:00:00", @day.to_formatted_s(:db)
    end
    def test_plugin
      day = Day.new DATE do |day|
        DayTestPlugin.new day
      end
      assert day.special?
      assert day.same?(day)
    end
    def test_method_missing
      assert_raises(NoMethodError) { @day.nothing_here }
    end
  end
  
  class MonthTest < Test::Unit::TestCase
    def setup
      @month = Month.new DATE
    end
    def test_weeks
      week = [1,2,3]
      assert @month.weeks.empty?
      @month.weeks << week
      assert @month.weeks.size == 1
      assert @month.weeks.first == week
    end
    def test_days
      assert @month.weeks.empty?
      @month.weeks << [1,2,3]
      @month.weeks << [4,5,6]
      assert @month.days.size == 6
      assert_equal [1,2,3,4,5,6], @month.days
    end
    def test_constructor_with_weeks
      week = [1,2,3]
      @month = Month.new DATE, [week]
      assert @month.weeks.size == 1
      assert @month.weeks.first == week
    end
    def test_proxy
      assert_equal "2005-05-01 00:00:00", @month.to_formatted_s(:db)
    end
  end
  
  class YearTest < Test::Unit::TestCase
    def setup
      @year = Year.new DATE
    end
    def test_months
      month = "foo"
      assert @year.months.empty?
      @year.months << month
      assert @year.months.size == 1
      assert @year.months.first == month
    end
    def test_constructor_with_months
      month = "foo"
      @year = Year.new DATE, [month]
      assert @year.months.size == 1
      assert @year.months.first == month
    end
    def test_proxy
      assert_equal "2005-01-01 00:00:00", @year.to_formatted_s(:db)
    end    
  end
  
end