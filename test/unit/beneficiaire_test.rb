#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class BeneficiaireTest < Test::Unit::TestCase
  fixtures :beneficiaires, :contrats, :identifiants

  def test_nom
    b = Beneficiaire.find 1
    b2 = Beneficiaire.new( 
      :client_id => 1,
      :beneficiaire_id => 1,
      :identifiant_id => 44)
    assert b2.save

    assert_equal b.nom, 'Hélène Parmentier'
    assert_equal b2.nom, ''
  end
  
  def test_contrat_ids
    b = Beneficiaire.find 1
    assert_equal b.contrat_ids, [1]
  end
end
