#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class LogicielTest < Test::Unit::TestCase
  fixtures :logiciels

  def test_to_param
    software = Logiciel.find 1
    assert_equal software.to_param, '1-ANT'
  end
  def test_to_s
    software = Logiciel.find 1
    assert_equal software.to_s, 'ANT'
  end
end
