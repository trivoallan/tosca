#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class SupportTest < Test::Unit::TestCase
  fixtures :supports

  def test_to_s
    assert_equal Support.find(1).to_s, 'Open from 7h to 19h'
  end
  def test_interval
    s = Support.find(1)
    assert_equal s.interval,12
  end
  def test_interval_in_seconds
    s = Support.find 1
    assert_equal s.interval_in_seconds, 43200
  end
end
