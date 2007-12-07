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
    c= Client.new(:name => 'Grellier Airlines')
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
    assert_not_nil c.name
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
    c = clients( :client_00001 )
    c.update_attributes(:name => "titi", :description => "la femme de toto",
      :mailingliste=> "titi@laposte.net",
      :adresse => "les champs Élysées 95000 Paris", :image_id => 1,
      :code_acces => "4242")
    assert_equal c.name, "titi"
    assert_equal c.description, "la femme de toto"
    assert_equal c.mailingliste, "titi@laposte.net"
    assert_equal c.adresse, "les champs Élysées 95000 Paris"
    assert_equal c.image_id, 1
    assert_equal c.code_acces, "4242"
  end
  def test_destroy
    assert clients( :client_00001).destroy
  end

  def test_name
    c = clients( :client_00001)
    assert_equal c.name, c.to_s
    assert_equal c.to_param, "1-toto"
  end
  def test_severites
    assert_equal clients(:client_00001).severites, Severite.find(:all)
  end

  def test_contrat_ids
    assert_equal Client.find(5).contrat_ids, []
    # 00004 => linagorien
    assert_equal clients(:client_00004).contrat_ids, [ 2 ]
  end
  def test_support_distribution
    assert_equal clients(:client_00004).support_distribution, true
    assert_equal clients(:client_00002).support_distribution, false
  end

  def test_beneficiaire_ids
    assert_equal clients(:client_00001).beneficiaire_ids, [1]
    assert_equal clients(:client_00004).beneficiaire_ids, []
  end

  def test_logiciels
    # case customer is Linagora
    assert_equal clients(:client_00004).logiciels, Logiciel.find(:all)
    # case customer isn't Linagora
    assert_equal Client.find(2).logiciels, [Logiciel.find(1)]
  end

  def test_typedemandes
    assert_equal clients(:client_00002).typedemandes, Typedemande.find(1,2).reverse
  end

  def test_contributions
    assert_equal clients(:client_00001).contributions, []
  end

  def test_inactive
    c = clients(:client_00001)
    c.inactive = true
    assert c.save
    assert_equal c.name , "<strike>toto</strike>"
    c.beneficiaires.each do |b|
      assert b.user.inactive?
    end
  end

end
