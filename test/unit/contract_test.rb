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

class ContractTest < Test::Unit::TestCase
  fixtures :all

  def test_to_strings
    check_strings Contract, :start_date_formatted, :end_date_formatted
  end

  def test_dates
    c = Contract.find(1)
    # Schedule check
    assert c.opening_time <= c.closing_time
    c.opening_time = -1
    assert !c.save
    c.opening_time = 25
    assert !c.save
    c.opening_time = 12
    c.closing_time = 9
    assert !c.save
    c.opening_time = 9
    c.closing_time = 12
    assert c.save
  end

  def test_invervals
    c = Contract.find(:first)
    interval = c.interval
    assert_equal c.interval_in_seconds, interval * 1.hour
  end

  def test_softwares
    Contract.find(:first).softwares.each{ |l| assert l.is_a?(Software)}
  end

  def test_issues
    c = Contract.find :first
    c.issues.each{ |d|
      assert d.is_a?(Issue)
      assert_equal d.contract_id, c.id
    }
  end

  def test_typeissues
    Contract.find(:all).each do |c|
      c.typeissues.each{ |td| assert_kind_of Typeissue, td }
    end
  end

  def test_credit?
    Contract.find(:first).credit?
  end

  def test_find_recipients_select
    recipients = Contract.find(:first).find_recipients_select
    assert !recipients.empty?
  end

  def test_scope
    Contract.set_scope([Contract.find(:first).id])
    Contract.find(:all)
    Contract.remove_scope
  end

  def test_engineer_users
    Contract.find(:all).each do |c|
      c.engineer_users.each { |i|
        assert_kind_of User, i
        assert i.ingenieur
      }
    end
  end

  def test_engineers
    Contract.find(:all).each do |c|
      c.engineers.each { |i|
        assert_kind_of User, i
        assert i.ingenieur
      }
    end
  end

end
