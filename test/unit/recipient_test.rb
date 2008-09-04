#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
