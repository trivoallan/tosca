require File.dirname(__FILE__) + '/../test_helper'

class StatutTest < Test::Unit::TestCase
  fixtures :statuts, :recipients

  def test_to_strings
    check_strings Statut
  end

  def test_possible
    recipient = recipients(:recipient_00001)

    Statut.find(:all).each{ |status|
      assert status.possible(recipient)
      assert status.possible
    }
  end
end
