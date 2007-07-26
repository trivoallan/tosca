#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class DocumentTest < Test::Unit::TestCase
  fixtures :documents

  def test_create_delete_document

    # titre must have at least 3 characters.
    # If no titre is precised, I cannot save my document
    d= Document.new( :titre => "document")
    assert d.save

    # id must exists
    assert_not_nil d.id
    # id must be an integer, not NULL
    d.update_attribute :id, "un entier"
    assert_kind_of Integer, d.id
    d.update_attribute :id, 'NULL'
    assert_not_nil d.id

    assert d.destroy

  end
  def test_update
    d = documents(:migration_lotus)
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
    
  end
  
  # Id MUST be unique
  def test_same_id
    assert_raise( ActiveRecord::RecordNotSaved ){
      Document.new( :id => 1, :titre => "fdfdf").save!
    }
  end
  # Title MUST have between 3 and 60 characters
  def test_title
    assert_raise( ActiveRecord::RecordInvalid){
      Document.new(:titre => "dd").save!
    }
    assert_raise( ActiveRecord::RecordInvalid){
      Document.new(:titre => "lsdkfmj smlkf jmdklf msdklfj 
        msdkfj mqkld sjmfkl qsjmdfklqjmd kfjmqsd lfkjqmdlkfjmqsd 
        klfjmqsdklfjmqsdlkfj").save!
    }
  end
  def test_nomfichier
    assert_equal documents(:migration_lotus).nomfichier, 
      "MINEFI_SLL_DLY_007_ETU_SI2_EtudeMigrationLotus_v1.0_pdf_.zip"
  end
  
  
  
  def test_updated_and_date_delivery_on_formatted
    assert_equal documents(:migration_lotus).updated_on_formatted, "26.07.2007 11:35"
    assert_equal documents(:doc_date_delivery).date_delivery_on_formatted, "29.07.2007 "
  end
  
  def test_to_param
    assert_equal documents(:migration_lotus).to_param, "1-Etude-Migration-Lotus-SI2-"
  end

end
