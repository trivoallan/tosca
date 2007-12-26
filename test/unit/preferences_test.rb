require File.dirname(__FILE__) + '/../test_helper'

class PreferencesTest < Test::Unit::TestCase
  fixtures :preferences

  def test_to_strings
    check_strings Preference
  end
end
