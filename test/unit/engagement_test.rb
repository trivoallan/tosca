#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class EngagementTest < Test::Unit::TestCase
  fixtures :engagements

  def test_presence_of_correction_and_contournement
    e = Engagement.new
    assert !e.save
    e.correction, e.contournement = 0,0
    assert !e.save
    e.correction, e.contournement = 2, 0.16
    assert e.save
  end

  def test_contourne
    e = Engagement.find 1
    e_inifite = Engagement.find 2
    assert e.contourne(60)
    assert !e.contourne(600)
    assert e_inifite
  end
  def test_corrige
    e = Engagement.find 1
    e_inifite = Engagement.find 2
    assert e.corrige(60)
    assert !e.corrige(6000000)
    assert e_inifite
  end

end
