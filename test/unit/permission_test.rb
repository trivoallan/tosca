#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < Test::Unit::TestCase
  fixtures :permissions

  def test_to_s
    p = Permission.find 11
    assert !p.to_s.blank?
    assert p.to_s.is_a?(String)
  end
end
