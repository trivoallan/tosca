#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class CompetenceTest < Test::Unit::TestCase
  fixtures :competences

  # Replace this with your real tests.
  def test_to_s 
    c = Competence.find 1
    assert_equal c.to_s, 'C'
  end
end
