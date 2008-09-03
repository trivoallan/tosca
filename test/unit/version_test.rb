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

  def test_compare
    ff_1_5 = versions(:version_ff_1_5)
    ff_2_0_0_12 = versions(:version_ff_2_0_0_12)
    ff_2_0_0_13 = versions(:version_ff_2_0_0_13)
    ff_2_generic = versions(:version_ff_2_generic)
    ff_3_generic = versions(:version_ff_3_generic)

    openoffice = logiciels(:logiciel_00001) # OpenOffice.org

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
