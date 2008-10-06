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

class CommitmentTest < Test::Unit::TestCase
  fixtures :commitments, :severities, :typeissues

  def test_to_strings
    check_strings Commitment
  end

=begin
  def test_presence_of_correction_and_workaround
    e = Commitment.new
    assert !e.save
    e.correction, e.workaround = 0,0
    assert !e.save
    e.correction, e.workaround = 2, 0.16 # 0.16 stands for 4 hours
    assert e.save
  end

  def test_contourne
    e = Commitment.find 1
    e_inifite = Commitment.find 2
    assert e.contourne(60)
    assert !e.contourne(600)
    assert e_inifite
  end
  def test_corrige
    e = Commitment.find 1
    e_inifite = Commitment.find 2
    assert e.corrige(60)
    assert !e.corrige(6000000)
    assert e_inifite
  end
=end
end
