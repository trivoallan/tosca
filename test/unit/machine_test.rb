#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class MachineTest < Test::Unit::TestCase
  fixtures :machines

  def test_to_s
    m = Machine.find 1
    m_without_acces = Machine.find 2
    assert_equal m.to_s, 'socle2004.ossa (192.168.1.106)'
    assert_equal m_without_acces.to_s, '-'
  end
end
