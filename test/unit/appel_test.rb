require File.dirname(__FILE__) + '/../test_helper'

class AppelTest < Test::Unit::TestCase
  fixtures :appels, :ingenieurs, :contrats

#  def test_beginning_before_end
#    a= Apple.new(
#    assert_raise( ActiveRecord::RecordInvalid) {
#      a.update_attribute!(:fin, "2007-03-01 16:41:00" )
#    }
#  end
  
  def test_validates_presence_of_ingenieur_and_contrat_on_create
    ing = Ingenieur.find :first
    cont = Contrat.find :first
    assert !Appel.new.save
    assert !Appel.new(:ingenieur => ing).save
    assert !Appel.new(:contrat => cont).save
    assert Appel.new(:contrat => cont, :ingenieur => ing).save
  end
  
end
