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

class TeamTest < ActiveSupport::TestCase
  fixtures :teams, :users, :contracts

  #I see no tests for this model (for the momentt
  def test_to_param
    ossa = teams(:team_ossa)
    support = teams(:team_support)

    assert_equal ossa.to_param, "1-OSSA"
    assert_equal support.to_param, "2-Support"
  end

  def test_engineers_id
    Team.all.each do |t|
      t.engineers_id.each do |id|
        user = User.find(id)
        assert user
        assert user.engineer?
        assert user.team.id == t.id
      end
    end
  end

  def test_engineers_collection_select
    Team.all.each do |t|
      t.engineers_collection_select.each do |e|
        user = User.find(e.id)
        assert user.engineer?
        assert user.team.id = t.id
      end
    end
  end

  def test_issues
    Team.all.each do |t|
      t.issues.each do |i|
        assert_kind_of Issue, i
        assert t.contract_ids.include?(i.contract_id)
      end
    end
  end

end
