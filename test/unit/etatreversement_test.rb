#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class EtatreversementTest < Test::Unit::TestCase
  fixtures :etatreversements

  def test_to_strings
    check_strings Etatreversement
  end
end
