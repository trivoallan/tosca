require File.dirname(__FILE__) + '/../test_helper'

class StatutTest < Test::Unit::TestCase
  fixtures :statuts, :beneficiaires

  def test_to_strings
    check_strings Statut
  end

  def test_possible
    recipient = beneficiaires(:beneficiaire_00001)

    Statut.find(:all).each{ |status|
      assert status.possible(recipient)
      assert status.possible
    }
  end
end
