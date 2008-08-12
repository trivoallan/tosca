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
