#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class IngenieurTest < Test::Unit::TestCase
  fixtures :ingenieurs, :contrats, :contrats_ingenieurs

  def test_to_strings
    check_strings Ingenieur
  end

  def test_find_select_by_contrat_id
    ids = ingenieurs(:ingenieur_00001).find_select_by_contrat_id
    ids.each { |i|
      inge =  Ingenieur.find(i.id)
      assert inge
      assert_equal inge.name, i.name
    }
  end

=begin
  Deprecated
  def test_find_ossa
    i = Ingenieur.find 1,2,3
    assert_equal Ingenieur.find_ossa(:all), i
  end
  def test_find_presta
    i = Ingenieur.find 4
    assert_equal Ingenieur.find_presta(:all), [i]
  end
=end
  def test_contrat_ids
    check_ids ingenieurs(:ingenieur_00001).contrat_ids, Contrat
  end
  def test_client_ids
    check_ids ingenieurs(:ingenieur_00001).client_ids, Client
  end
end
