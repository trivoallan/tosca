#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class IngenieurTest < Test::Unit::TestCase
  fixtures :ingenieurs, :contrats, :contrats_ingenieurs

  def test_find_ossa
    i = Ingenieur.find 1
    assert_equal Ingenieur.find_ossa(:all), [i]
  end
  def test_find_presta
    i = Ingenieur.find 2
    assert_equal Ingenieur.find_presta(:all), [i]
  end

  def test_contrat_ids
    i = Ingenieur.find 1
    assert_equal i.contrat_ids, [2,3,1]
  end
  def test_client_ids
    i = Ingenieur.find 1
    assert_equal i.client_ids, [1,2]
  end
  def test_nom
    engineer = Ingenieur.find 2
    assert_equal engineer.nom, 'Guillaume Dufloux'
  end
end
