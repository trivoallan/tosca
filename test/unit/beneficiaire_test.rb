require File.dirname(__FILE__) + '/../test_helper'

class BeneficiaireTest < Test::Unit::TestCase
  fixtures :beneficiaires, :clients, :contrats, :users

  def test_to_strings
    check_strings Beneficiaire
  end

  def test_contrat_ids
    Beneficiaire.find(:all).each { |b| check_ids b.contrat_ids, Contrat }
  end

end
