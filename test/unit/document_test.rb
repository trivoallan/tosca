#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < Test::Unit::TestCase
  fixtures :documents

  def test_create_update_delete_document

    # titre must have at least 3 characters.
    # If no titre is precised, I cannot save my document
    d= Document.new( :titre => "document")
    assert d.save
    d.update_attribute :titre ,"rr"
    assert !d.save 


    # id must exists
    assert_not_nil d.id
    # id must be an integer, not NULL
    d.update_attribute :id, "un entier"
    assert_kind_of Integer, d.id
    d.update_attribute :id, 'NULL'
    assert_not_nil d.id
    #id must be unique :
    d.update_attribute :id, 1
    d2 = Document.new
    assert_raise( ActiveRecord::StatementInvalid ){
      d2.update_attribute :id, 1
    }

    d.update_attributes( :identifiant_id => 1, :typedocument_id => 1,
      :client_id => 2, :titre => "bonjour (lemonde)",
      :description => "d fs fd àfi @ © àf«", 
      :created_on =>"2006-09-05 18:08:49", :updated_on=>"2006-09-05 18:43:02",
      :date_delivery => "2007-09-05 18:08:49"
    )

    assert_equal d.identifiant_id, 1
    assert_equal d.typedocument_id, 1
    assert_equal d.client_id, 2
    assert_equal d.titre, "bonjour (lemonde)"
    assert_equal d.description, "d fs fd àfi @ © àf«"
    assert_kind_of Time, d.created_on
    assert_kind_of Time, d.updated_on
    assert_kind_of Time, d.date_delivery

    assert d.destroy

    # tests of the methods :
    assert_kind_of String,d.date_delivery_on_formatted

    assert_equal d.to_param, "1-bonjour-lemonde-"
 
  end
end
