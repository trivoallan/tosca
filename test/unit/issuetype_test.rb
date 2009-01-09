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

class IssuetypeTest < Test::Unit::TestCase
  fixtures :issuetypes

  def test_to_strings
    check_strings Issuetype
  end


  def test_allowed_statuses_ids
    statuses = Statut.all
    Issuetype.all.each do |i|
      statuses.each do |s|
        assert_instance_of Array, i.allowed_statuses_ids(s)
      end
    end
  end

  def test_allowed_statuses
    statuses = Statut.all
    users = User.all
    Issuetype.all.each do |i|
      statuses.each do |s|
        users.each do |u|
          assert_instance_of Array, i.allowed_statuses(s, u)
        end
      end
    end
  end

end
