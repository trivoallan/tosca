#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ArchTest < Test::Unit::TestCase
  fixtures :arches

  # Replace this with your real tests.
  def test_to_s
    arch = Arch.find 1
    arch6 = Arch.find 6
    assert_equal arch.to_s, 'i386'
    assert_equal arch6.to_s, '<b>src</b>'
  end
end
