#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ContratTest < Test::Unit::TestCase
  fixtures :contrats, :contrats_engagements,:engagements,  :clients,
    :demandes, :demandes_paquets, :paquets, :typedemandes

  def test_ouverture_formatted
    c = Contrat.find 1
    assert_equal c.ouverture_formatted, '26.10.2005'
  end
  def test_cloture_formatted
    c = Contrat.find 1
    assert_equal c.cloture_formatted, '27.10.2008'
  end
  def test_find_engagement
    c = Contrat.find 1
    request = Demande.find 2
    e = Engagement.find 1
    assert_equal c.find_engagement(request), e
  end
  def test_demandes
    c = Contrat.find 3
    assert_equal c.demandes, [Demande.find(4)]
  end
  def test_typedemandes
    c = Contrat.find 1
    assert_equal c.typedemandes, [Typedemande.find(2)]
  end

  def test_to_s
    c = Contrat.find 1
    c_name_empty = Contrat.new(
      :client_id => Client.find(:first).id,
      :ouverture => "2006-11-25 12:20:00",
      :cloture => "2007-11-12 14:23:00",
      :rule_type => 'TimeTicket',
      :rule_id => 1
    )
    assert c_name_empty.save

    assert !c.to_s.blank?
  end
end
