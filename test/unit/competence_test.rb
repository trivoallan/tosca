#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class CompetenceTest < Test::Unit::TestCase
  fixtures :competences

  def test_to_strings
    check_strings Competence
  end
end
