require 'test/unit'

require File.dirname(__FILE__) + '/../lib/calendar_grid'

module CalendarGrid
  
  class BugsTest < Test::Unit::TestCase
    
    def test_entire_calendar_uses_correct_start_wday
      builder = CalendarGrid::Builder.new(Time.local(2005, 12, 1), 14) 
      builder.start_wday = 0
      grid = builder.build
      grid.months.each do |month|
        month.weeks.each do |week|
          day = week.first
          assert_equal 0, day.wday, "start of week, #{day} was #{day.wday}, not sunday"
        end
      end
    end
    
    def test_all_days_have_0_hour
      grid = CalendarGrid.build
      grid.months.each do |month|
        month.weeks.each do |week|
          week.each do |day|
            assert day.hour.zero?, "#{day} is not hour 0"
          end
        end
      end
    end
    
    def test_november_2007_does_not_have_duplicate_days_from_dst
      builder = CalendarGrid::Builder.new(Time.local(2007, 1, 1), 12)
      grid = builder.build
      month = grid.months[10]
      days = month.days.select { |d| !d.proxy? }.collect { |d| d.date.day }
      assert_equal (1..30).to_a, days
    end
    
  end

end

