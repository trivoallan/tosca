#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class IngenieurTest < Test::Unit::TestCase
  fixtures :ingenieurs, :contrats

  def test_nom
    engineer = Ingenieur.find 1
    assert_equal engineer.nom, 'Guillaume Dufloux'
  end
end
