#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class UrlreversementTest < Test::Unit::TestCase
  fixtures :urlreversements

  def test_presence_of_valeur_and_contribution_id
    u = Urlreversement.new
    assert !u.save
    u.valeur = 'une valeur'
    assert !u.save
    u.contribution_id = 1
    assert u.save
  end
  def test_name
    assert_equal Urlreversement.find(1).name, 
      "http://openoffice.org/monbugestici.html"
  end
  def test_to_s
    assert_equal Urlreversement.find(1).to_s, 
      "http://openoffice.org/monbugestici.html"
  end

end
