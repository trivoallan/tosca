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
require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  fixtures :workflows

  def test_to_strings
    check_strings Workflow
  end

  def test_allowed_status
    Workflow.all.each do |w|
      w.allowed_status.each do |s|
        assert_instance_of Statut, s
      end
    end
  end
end
