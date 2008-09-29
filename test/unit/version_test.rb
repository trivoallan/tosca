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
require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  fixtures :all

  def test_full_name
    v = versions(:version_ff_2_0_0_13)
    assert_equal("v2.0.0.13", v.full_name)
  end

  def test_full_software_name
    v = versions(:version_ff_2_0_0_13)
    assert_equal("Firefox v2.0.0.13", v.full_software_name)
  end

  def test_name
    v_specific = versions(:version_ff_2_0_0_13)
    assert_equal("2.0.0.13", v_specific.name)

    v_generic = versions(:version_ff_2_generic)
    assert_equal("2.*", v_generic.name)
  end
  
  def test_validation
    v = Version.new(:software_id => 1)
    assert !v.save
    
    v = Version.new(:software_id => 1)
    v.generic = true
    assert v.save
    assert_equal "*", v.to_s
    
    v = Version.new(:software_id => 1)
    v.generic = false
    v.name = ""
    assert !v.save
    
    v = Version.new(:software_id => 1)
    v.generic = false
    v.name = "2"
    assert v.save
    assert_equal "2", v.to_s
    
    v = Version.new(:software_id => 1)
    v.generic = true
    v.name = "2"
    assert v.save
    assert_equal "2.*", v.to_s
  end

  def test_compare
    ff_1_5 = versions(:version_ff_1_5)
    ff_2_0_0_12 = versions(:version_ff_2_0_0_12)
    ff_2_0_0_13 = versions(:version_ff_2_0_0_13)
    ff_2_generic = versions(:version_ff_2_generic)
    ff_3_generic = versions(:version_ff_3_generic)

    openoffice = softwares(:software_00001) # OpenOffice.org

    assert_equal(1, ff_2_0_0_13 <=> nil)
    assert_equal(1, ff_2_0_0_13 <=> openoffice)

    assert_equal(1, ff_2_generic <=> ff_2_0_0_13)
    assert_equal(-1, ff_2_0_0_13 <=> ff_2_generic)

    assert_equal(-1, ff_2_generic <=> ff_3_generic)

    assert(ff_2_0_0_13 >= ff_2_0_0_12)
    assert(ff_2_generic < ff_3_generic)
    assert(ff_2_0_0_12 > ff_1_5)
    assert(ff_2_generic > ff_2_0_0_13)
  end

end
