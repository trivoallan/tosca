#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class FichierbinairesTest < Test::Unit::TestCase
  fixtures :fichierbinaires

  def test_to_strings
    check_strings Fichierbinaire
  end
end
