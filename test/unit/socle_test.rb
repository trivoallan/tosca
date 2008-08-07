require File.dirname(__FILE__) + '/../test_helper'

class SocleTest < Test::Unit::TestCase
  fixtures :socles, :clients, :clients_socles

  def test_to_strings
    check_strings Socle
  end

  def test_scope
    Socle.set_scope([Client.find(:first).id])
    Socle.remove_scope
  end

end
