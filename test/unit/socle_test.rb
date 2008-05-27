require File.dirname(__FILE__) + '/../test_helper'

class SocleTest < Test::Unit::TestCase
  fixtures :socles, :clients, :clients_socles

  def test_to_strings
    check_strings Socle
  end

end
