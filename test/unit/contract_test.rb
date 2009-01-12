#
# Copyright (c) 2006-2009 Linagora
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
    c = Contract.first(:order => :id)
    interval = c.interval
    assert_equal c.interval_in_seconds, interval * 1.hour
  end

  def test_softwares
    Contract.first(:order => :id).softwares.each{ |l| assert l.is_a?(Software)}
  end

  def test_issues
    c = Contract.find :first
    c.issues.each{ |d|
      assert d.is_a?(Issue)
      assert_equal d.contract_id, c.id
    }
  end

  def test_issuetypes
    Contract.all.each do |c|
      c.issuetypes.each{ |td| assert_kind_of Issuetype, td }
    end
  end

  def test_credit?
    Contract.first(:order => :id).credit?
  end

  def test_find_recipients_select
    recipients = Contract.first(:order => :id).find_recipients_select
    assert !recipients.empty?
  end

  def test_scope
    Contract.set_scope([Contract.first(:order => :id).id])
    Contract.all
    Contract.remove_scope
  end

  def test_engineer_users
    Contract.all.each do |c|
      c.engineer_users.each { |i|
        assert_kind_of User, i
        assert i.id
      }
    end
  end

  def test_engineers
    Contract.all.each do |c|
      c.engineers.each do |i|
        assert_kind_of User, i
        assert i.id
      end
    end
  end

  def test_subscribers
    Contract.all.each do |c|
      c.subscribers.each do |s|
        assert_kind_of User, s
        assert s.id
        assert s.contracts_subscribed.include?(c)
      end
    end
  end

  def test_tam_subscribed
    Contract.all.each do |c|
      #We only test contracts with a tam
      assert c.subscribed?(c.tam) if c.tam
    end
  end

  def test_create
    tam = User.first(:order => :id)
    c = Contract.new(:client => Client.first,
      :opening_time => 8,
      :closing_time => 19,
      :creator => tam,
      :rule => Rules::Component.first,
      :tam => tam,
      :start_date => "2007-12-24",
      :end_date => "2012-12-24")
    assert c.save!
    assert c.subscribed?(tam)
  end

  def test_find_commitment
    Contract.all.each do |c|
      c.issues.each do |i|
        assert_instance_of Commitment, c.find_commitment(i)
      end
    end
  end

  def test_total_elapsed
    Contract.all.each do |c|
      total = 0
      c.issues.each do |r|
        total += r.elapsed.until_now
      end
      assert_equal(c.total_elapsed, total)
    end
  end

end
