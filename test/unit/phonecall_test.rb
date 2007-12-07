require File.dirname(__FILE__) + '/../test_helper'

class PhonecallTest < Test::Unit::TestCase
  fixtures :phonecalls, :ingenieurs, :contrats,
    :beneficiaires, :users, :clients

  def test_validates_presence_of_ingenieur_and_contrat_on_create
    ing = ingenieurs(:ingenieur_00001)
    cont = contrats(:contrat_00001)
    a = Phonecall.new(:start => "2007-03-16 22:41:00",
                      :end => "2007-03-17 22:42:00")
    b = Phonecall.new(:start => "2007-03-16 22:41:00",
                      :end => "2007-03-17 22:42:00")
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
    a = Phonecall.new(
      :start => "2007-03-16 16:41:00",
      :end => "2007-03-16 22:41:00",
      :demande_id => nil,
      :ingenieur_id => 1,
      :beneficiaire_id => 1,
      :contrat_id => 2)
    assert !a.save
  end

  def test_end_formatted
    a = Phonecall.find 1
    assert_equal a.end_formatted, "16.03.2007 at 22h41"
  end

  def test_start_formatted
    a = Phonecall.find 1
    assert_equal a.start_formatted, "16.03.2007 at 16h41"
  end

  def test_length
    a = Phonecall.find 1
    length = a.end - a.start
    assert_equal length, 21600
  end

  def test_contrat_name
    a = Phonecall.find 1
    assert(!a.contrat_name.blank?)
  end

  def test_ingenieur_name
    a = Phonecall.find 1
  end
end
