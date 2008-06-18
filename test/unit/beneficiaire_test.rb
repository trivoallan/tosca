require File.dirname(__FILE__) + '/../test_helper'

class BeneficiaireTest < Test::Unit::TestCase
  fixtures :beneficiaires, :clients, :contracts, :users, :contracts_users

  def test_to_strings
    check_strings Beneficiaire
  end

  def test_contract_ids
    Beneficiaire.find(:all).each { |b| check_ids b.contract_ids, Contract }
  end

  def test_contracts
    customer = beneficiaires(:beneficiaire_00001)
    contracts = customer.user.contracts
    
    assert_equal contracts.size, 1
    assert_equal contracts.first.id, 1
  end
  
end
