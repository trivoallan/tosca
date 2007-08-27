#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class CompetenceTest < Test::Unit::TestCase
  fixtures :competences

  # Replace this with your real tests.
  def test_to_s 
    c = Competence.find 1
    assert !c.to_s.blank?
    assert c.to_s.is_a?(String)
  end
end
