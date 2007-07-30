#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients, :typedemandes, :contrats, :beneficiaires

  def test_client_create
    c= Client.new
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
  # Currently ersase c : 
  def test_not_same_id_on_update
    c = clients( :toto )
    c1= clients(:guy)
    c.update_attribute(:id, 1)
    assert !c1.update_attribute(:id,1)
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
    assert_equal clients(:toto).contrat_ids, "1,2"
    assert_equal clients(:linagorien).contrat_ids, "0"
  end
  def test_support_distribution
    assert_equal clients(:toto).support_distribution, true
    assert_equal clients(:guy).support_distribution, false
  end
  
  def test_beneficiaire_ids
    assert_equal clients(:toto).beneficiaire_ids, [1,2]
    assert_equal clients(:linagorien).beneficiaire_ids, []
  end
  
  def test_logiciels
    # case customer is Linagora
    assert_equal Logiciel.find(:all), clients(:linagorien).logiciels
    # TODO case customer isn't Linagora
  end
  
  # Need at least one request to test these tonctions
  # TODO when request table will be migrated : improve these tests
  def test_typedemandes
    assert clients(:toto).typedemandes
  end
  def test_contributions
    assert_equal clients(:toto).contributions, []
  end
  
  

end
