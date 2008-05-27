require File.dirname(__FILE__) + '/../test_helper'

class ArchTest < Test::Unit::TestCase
  fixtures :arches

  def test_to_strings
    check_strings Arch
  end
end
