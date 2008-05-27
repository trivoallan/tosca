require File.dirname(__FILE__) + '/../test_helper'

class DistributeurTest < Test::Unit::TestCase
  fixtures :distributeurs

  def test_to_strings
    check_strings Distributeur
  end
end
