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

class ReleaseTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_full_name
    release_ff_2_0_0_13_r_1 = releases(:release_ff_2_0_0_13_r_1)
    assert_equal("#{release_ff_2_0_0_13_r_1.version.full_name} r1", 
      release_ff_2_0_0_13_r_1.full_name)
  end
    
  def test_full_software_name
    release_ff_2_0_0_13_r_1 = releases(:release_ff_2_0_0_13_r_1)
    assert_equal("#{release_ff_2_0_0_13_r_1.version.full_software_name} r1", 
      release_ff_2_0_0_13_r_1.full_software_name)
  end

   def test_compare
     release_ff_2_0_0_13_r_1 = releases(:release_ff_2_0_0_13_r_1)
     release_ff_2_0_0_13_r_2 = releases(:release_ff_2_0_0_13_r_2)
     
     assert(release_ff_2_0_0_13_r_1 < release_ff_2_0_0_13_r_2)
   end
  
  end
