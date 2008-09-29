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

class KnowledgeTest < ActiveSupport::TestCase
  fixtures :knowledges, :competences, :softwares, :ingenieurs

  # Common test, see the Wiki for more info
  def test_to_strings
    check_strings Knowledge
  end

  def test_validation
    obj = Knowledge.new(:competence => nil, :software => nil)
    assert !obj.valid?
    obj = Knowledge.new(:competence => Competence.find(:first),
                        :software => Software.find(:first),
                        :ingenieur => Ingenieur.find(:first),
                        :level => 3)
    assert !obj.valid?
    obj.competence = nil
    assert obj.valid?
  end
end
