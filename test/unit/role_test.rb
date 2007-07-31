#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :roles

  def test_to_s
    r = Role.find 1
    assert_equal r.to_s, 'admin'
  end
end
