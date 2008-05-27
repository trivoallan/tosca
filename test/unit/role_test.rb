require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :roles

  def test_to_strings
    check_strings Role
  end
end
