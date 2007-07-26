#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ClientTest < Test::Unit::TestCase
  fixtures :clients

  def test_client_create_update_delete
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
    c2 = Client.new
    assert_raise( ActiveRecord::StatementInvalid ){
      c2.update_attribute :id, 1
    }

    # Some attributes shouldn't be null :
    assert_not_nil c.nom
    assert_not_nil c.description
    assert_not_nil c.mailingliste
    assert_not_nil c.adresse
    assert_not_nil c.code_acces


    c.update_attributes(:nom => "toto", :support_id => 1, 
      :description => "éééà @ bonj\"our", :mailingliste=> "totoaposte.net",
      :adresse => "les champs Élysées 95000 Paris", :image_id => 1, 
      :code_acces => "lenomdemonchien", :beneficiaires_count => 21
      )
    assert_equal c.nom, "toto"
    assert_equal c.support_id, 1
    assert_equal c.description, "éééà @ bonj\"our"
    assert_equal c.mailingliste, "totoaposte.net"
    assert_equal c.adresse, "les champs Élysées 95000 Paris"
    assert_equal c.image_id, 1
    assert_equal c.code_acces, "lenomdemonchien"
    assert_equal c.beneficiaires_count, 21


    #severites
    assert_equal c.severites.length, Severite.count
    # name :
    assert_equal c.nom, c.to_s
    assert_equal c.to_param, "1-toto"

    #contrat_ids
    assert_equal c.contrat_ids, '0'
    #beneficiaire_ids
    assert_kind_of Array, c.beneficiaire_ids

    assert_equal c.logiciels, []
    assert_equal c.ingenieurs, []
    assert_equal c.contributions, []
    assert_kind_of Array, c.typedemandes


    assert c.destroy
  end
  
end
