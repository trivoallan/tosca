#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class DemandeTest < Test::Unit::TestCase
  fixtures :demandes, :typedemandes, :severites, :statuts,
    :beneficiaires, :clients, :users, :paquets

  def test_to_strings
    check_strings Demande, :resume, :description
  end

  def test_presence_of_attributes
    request = Demande.new
    assert !request.save
    assert request.errors.on(:resume)

    #length of the resume : 3..60
    request.resume = 'gg'
    assert !request.save
    request.resume = 'ddfkljmdfklmdjsfl kjfml skfjmlsdkjmflqsdkjfmldmfjqlkdjmflskfjmlqskd fmjskdmfjqmsldkfjm'
    assert !request.save
    request.resume ='resume'

    # must have a recipient
    assert !request.save
    assert request.errors.on(:beneficiaire)
    request.beneficiaire = Beneficiaire.find 1
    # must have a description
    assert !request.save
    assert request.errors.on(:description)
    request.description = 'hello request'
    # must have a status and a severity != 0
    assert !request.save
    assert request.errors.on(:statut)
    assert request.errors.on(:severite)
    request.statut = Statut.find 1
    request.severite = Severite.find 1
    # must have a contrat_id
    assert request.errors.on(:contrat)
    assert !request.save
    request.contrat = Contrat.find 1

    assert request.save

    # a request must have 5 letters in its description
    request.description = 'test'
    assert !request.save
    request.description = 'hello request'

    # commentaire table must have things now ...
    c = Commentaire.find :first, :conditions => { :demande_id => request.id }
    assert_equal c.demande_id, request.id
    assert_equal c.severite, request.severite
    assert_equal c.statut, request.statut
    assert_equal c.ingenieur, request.ingenieur
  end

=begin
  TODO : rework with rule contract model
  def test_client
    r = Demande.find 1,2
    c = Client.find 1
    assert_equal r[0].client, c
    assert_equal r[1].client, c
  end

  def test_respect_contournement_and_correction
    r = Demande.find 3
    c = Contrat.find 2
    assert_kind_of String, r.respect_contournement(c.id)
    assert_kind_of String, r.respect_correction(c.id)
  end

  # No test for affiche_temps_ecoule and affiche_temps_correction
  # because the display of the time may change
  def test_temps_correction
    r = Demande.find 3
    assert_operator r.temps_correction, '>=', 0
    assert_equal r.temps_contournement, 0
  end
  def test_delais_correction
    r = Demande.find 3
    assert_equal r.delais_correction, 475200.0
  end
  def test_temps_rappel
    r = Demande.find 3
    assert_equal r.temps_rappel, 0
    assert_equal r.affiche_temps_rappel, '-'
  end
  def test_engagement
    r = Demande.find 3
    e = Engagement.find 1
    assert_equal r.engagement(3), e
  end
  def test_affiche_temps_ecoule
    r = Demande.find 3
    assert r.affiche_temps_ecoule
  end
=end

end
