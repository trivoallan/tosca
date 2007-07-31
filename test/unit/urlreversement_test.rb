#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class UrlreversementTest < Test::Unit::TestCase
  fixtures :urlreversements

  def test_presence_of_valeur
    assert !Urlreversement.new.save
  end
  def test_nom
    assert_equal Urlreversement.find(1).nom, 
      "http://openoffice.org/monbugestici.html"
  end
  def test_to_s
    assert_equal Urlreversement.find(1).to_s, 
      "http://openoffice.org/monbugestici.html"
  end

end
