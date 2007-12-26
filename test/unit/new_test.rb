require File.dirname(__FILE__) + '/../test_helper'

class NewTest < Test::Unit::TestCase
  fixtures :news

  def test_to_strings
    check_strings New
  end
end
