#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class SeveriteTest < Test::Unit::TestCase
  fixtures :severites

  def test_to_strings
    check_strings Severite
  end
end
