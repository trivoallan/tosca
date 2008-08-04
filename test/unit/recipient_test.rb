require File.dirname(__FILE__) + '/../test_helper'

class RecipientTest < Test::Unit::TestCase
  fixtures :recipients, :clients, :contracts, :users, :contracts_users

  def test_to_strings
    check_strings Recipient
  end

  def test_contract_ids
    Recipient.find(:all).each { |b| check_ids b.contract_ids, Contract }
  end

  def test_contracts
    customer = recipients(:recipient_00001)
    contracts = customer.contracts

    assert_equal contracts.size, 1
    assert_equal contracts.first.id, 1
  end

end
