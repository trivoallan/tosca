#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ArchTest < Test::Unit::TestCase
  fixtures :arches

  def test_to_strings
    check_strings Arch
  end
end
