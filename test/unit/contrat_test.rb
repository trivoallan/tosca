#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ContratTest < Test::Unit::TestCase
  fixtures :contrats, :logiciels, :paquets, :contrats_engagements,:engagements,
    :demandes, :ossas, :time_tickets, :clients

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

=begin TODO
  def test_find_engagement
    c = Contrat.find :first
    request = Demande.find :first
    e = Engagement.find :first
    assert_equal c.find_engagement(request), e
  end
=end

  def test_demandes
    c = Contrat.find :first
    c.demandes.each{ |d|
      assert d.is_a?(Demande)
      assert_equal d.contrat_id, c.id
    }
  end

  def test_typedemandes
    Contrat.find(:all).each do |c|
      typedemandes.each{ |td| assert_kind_of Typedemande, td }
    end
  end

  def test_engineer_users
    Contrat.find(:all).each do |c|
      c.engineer_users.each{ |i|
        assert_kind_of User, i
        assert i.ingenieur
      }
    end
  end

end
