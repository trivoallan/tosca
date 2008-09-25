require 'test/unit'

require File.dirname(__FILE__) + '/../lib/calendar_grid'

# This class is used to add functionality to a CalendarGrid::Day object.
class ThirdDayPlugin
  def initialize(day)
    @day = day
  end
  def day_is_mod_three?
    @day.day % 3 == 0
  end
end

class PluginTest < Test::Unit::TestCase

  def setup
    @day = CalendarGrid::Day.new(Time.local(2005,5,8)) do |day|
      ThirdDayPlugin.new day
    end
    @third_day = CalendarGrid::Day.new(Time.local(2005,5,9)) do |day|
      ThirdDayPlugin.new day
    end
  end
  
  def test_third?
    assert !@day.day_is_mod_three?
    assert @third_day.day_is_mod_three?
  end
  
end
