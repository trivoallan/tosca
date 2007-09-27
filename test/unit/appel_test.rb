require File.dirname(__FILE__) + '/../test_helper'

class AppelTest < Test::Unit::TestCase
  fixtures :appels, :ingenieurs, :contrats, 
    :beneficiaires, :identifiants, :clients

  def test_validates_presence_of_ingenieur_and_contrat_on_create
    ing = ingenieurs(:ingenieur_00001)
    cont = contrats(:contrat_00001)
    a= Appel.new( :debut=> "2007-03-16 22:41:00",
                     :fin => "2007-03-17 22:42:00")
    b= Appel.new( :debut=> "2007-03-16 22:41:00",
                     :fin => "2007-03-17 22:42:00")
    #neither engineer nor contrat
    assert !a.save
    # only an enginner
    a.ingenieur = ing
    assert !a.save
    #only a contract
    b.contrat = cont
    assert !b.save
    #both enginner and contract
    a.contrat = cont
    assert a.save
  end
  def test_client_id
    a = Appel.new(
      :debut => "2007-03-16 16:41:00",
      :fin => "2007-03-16 22:41:00",
      :demande_id => nil,
      :ingenieur_id => 1,
      :beneficiaire_id => 1,
      :contrat_id => 2)
    assert !a.save
  end
  def test_fin_formatted
    a = Appel.find 1
    assert_equal a.fin_formatted, "16.03.2007 at 22h41"
  end
  def test_debut_formatted
    a = Appel.find 1
    assert_equal a.debut_formatted, "16.03.2007 at 16h41"
  end
  def test_duree
    a = Appel.find 1
    duree = a.fin - a.debut
    assert_equal duree, 21600
  end
  
  def test_contrat_nom
    a = Appel.find 1
    assert(!a.contrat_nom.blank?)
  end
  def test_ingenieur_nom
    a = Appel.find 1
  end
end
