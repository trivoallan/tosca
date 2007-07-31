#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class SocleTest < Test::Unit::TestCase
  fixtures :socles

  def test_to_s
    assert_equal Socle.find(1).to_s, 'dgi2004-1.32'
  end
end
