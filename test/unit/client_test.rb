#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients, :typedemandes, :contrats, :beneficiaires, :paquets,
    :logiciels, :engagements, :contrats_engagements

  def test_client_create
    # a customer must have a name
    c= Client.new()
    assert c.save == false
    c= Client.new(:nom => 'Grellier Airlines')
    assert c.save 

    # a customer must have an id
    assert_not_nil c.id
    # id must be an integer, not NULL
    c.update_attribute :id, "un entier"
    assert_kind_of Integer, c.id
    c.update_attribute :id, 'NULL'
    assert_not_nil c.id
    #id must be unique :
    c.update_attribute :id, 1

    # Some attributes shouldn't be null :
    assert_not_nil c.nom
    assert_not_nil c.description
    assert_not_nil c.mailingliste
    assert_not_nil c.adresse
    assert_not_nil c.code_acces

  end
  # Seems to retrun true, even if the record is not save
  def test_not_same_id_on_create
    assert !Client.new(:id => 1).save
  end

  def test_update
    c = clients( :toto )
    c.update_attributes(:nom => "titi", :support_id => 1, 
      :description => "la femme de toto", :mailingliste=> "titi@laposte.net",
      :adresse => "les champs Élysées 95000 Paris", :image_id => 1, 
      :code_acces => "lenomdeleurchien", :beneficiaires_count => 2
      )
    assert_equal c.nom, "titi"
    assert_equal c.support_id, 1
    assert_equal c.description, "la femme de toto"
    assert_equal c.mailingliste, "titi@laposte.net"
    assert_equal c.adresse, "les champs Élysées 95000 Paris"
    assert_equal c.image_id, 1
    assert_equal c.code_acces, "lenomdeleurchien"
    assert_equal c.beneficiaires_count, 2
  end
  def test_destroy
    assert clients( :toto).destroy
  end
  
  def test_name
    c = clients( :toto)
    assert_equal c.nom, c.to_s
    assert_equal c.to_param, "1-toto"
  end
  def test_severites
    assert_equal clients(:toto).severites, Severite.find(:all)
  end

  def test_contrat_ids
    assert_equal Client.find(5).contrat_ids, '0'
    assert_equal clients(:linagorien).contrat_ids, '2'
  end
  def test_support_distribution
    assert_equal clients(:linagorien).support_distribution, true
    assert_equal clients(:guy).support_distribution, false
  end
  
  def test_beneficiaire_ids
    assert_equal clients(:toto).beneficiaire_ids, [1]
    assert_equal clients(:linagorien).beneficiaire_ids, []
  end
  
  def test_logiciels
    # case customer is Linagora
    assert_equal clients(:linagorien).logiciels, Logiciel.find(:all)
    # case customer isn't Linagora
    assert_equal Client.find(2).logiciels, Logiciel.find(1,2)
  end
  
  def test_typedemandes
    assert_equal clients(:guy).typedemandes, Typedemande.find(1,2).reverse
  end
  def test_contributions
    assert_equal clients(:toto).contributions, []
  end
  
end
