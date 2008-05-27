require File.dirname(__FILE__) + '/../test_helper'

class LicenseTest < Test::Unit::TestCase
  fixtures :licenses

  def test_to_strings
    check_strings License
  end

end
