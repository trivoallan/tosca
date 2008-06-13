require File.dirname(__FILE__) + '/../test_helper'

class BeneficiaireTest < Test::Unit::TestCase
  fixtures :beneficiaires, :clients, :contracts, :users

  def test_to_strings
    check_strings Beneficiaire
  end

  def test_contract_ids
    Beneficiaire.find(:all).each { |b| check_ids b.contract_ids, Contract }
  end

end
