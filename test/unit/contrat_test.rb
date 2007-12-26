#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ContratTest < Test::Unit::TestCase
  fixtures :contrats, :logiciels, :paquets, :contrats_engagements,:engagements,
    :demandes

  def test_to_strings
    check_strings Contrat, :ouverture_formatted, :cloture_formatted
  end

  def test_dates
    c = Contrat.find 1
    # Schedule check
    assert c.heure_ouverture <= c.heure_fermeture
    c.heure_ouverture = -1
    assert !c.save
    c.heure_ouverture = 25
    assert !c.save
    c.heure_ouverture = 12
    c.heure_fermeture = 9
    assert !c.save
    c.heure_ouverture = 9
    c.heure_fermeture = 12
    assert c.save
  end

  def test_invervals
    c = Contrat.find(:first)
    interval = c.interval
    assert_equal c.interval_in_seconds, interval * 1.hour
  end

  def test_logiciels
    Contrat.find(:first).logiciels.each{ |l| assert l.is_a?(Logiciel)}
  end

  def test_find_engagement
    c = Contrat.find :first
    request = Demande.find :first
    e = Engagement.find :first
    assert_equal c.find_engagement(request), e
  end

  def test_demandes
    c = Contrat.find :first
    c.demandes.each{ |d|
      assert d.is_a?(Demande)
      assert_equal d.contrat_id, c.id
    }
  end

  def test_typedemandes
    Contrat.find(:first).typedemandes.each{ |td| assert td.is_a?(Typedemande)}
  end

end
