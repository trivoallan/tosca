require File.dirname(__FILE__) + '/../test_helper'

class DependanceTest < Test::Unit::TestCase
  fixtures :dependances

  def test_to_strings
    check_strings Dependance
  end
end
