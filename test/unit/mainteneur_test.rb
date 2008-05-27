require File.dirname(__FILE__) + '/../test_helper'

class MainteneurTest < Test::Unit::TestCase
  fixtures :mainteneurs

  def test_to_strings
    check_strings Mainteneur
  end
end
