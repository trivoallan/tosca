#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class BeneficiaireTest < Test::Unit::TestCase
  fixtures :beneficiaires, :contrats, :users

  def test_name
    b = Beneficiaire.find 1
    b2 = Beneficiaire.new( 
      :client_id => 1,
      :beneficiaire_id => 1,
      :user_id => 44)
    assert b2.save

    assert_equal b.name, 'Hélène Parmentier'
    assert_equal b2.name, ''
  end
  
  def test_contrat_ids
    b = Beneficiaire.find 1
    assert_equal b.contrat_ids, [1]
  end
end
