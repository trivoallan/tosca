#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class UrllogicielTest < Test::Unit::TestCase
  fixtures :urllogiciels, :logiciels

  def test_to_strings
    check_strings Urllogiciel
  end

  def test_presences
    u = Urllogiciel.new
    assert !u.save
    assert u.errors.on(:valeur)
    assert u.errors.on(:logiciel)

    software = logiciels(:logiciel_00001)
    u.update_attributes(:valeur => 'rubyonrails.org', :logiciel => software)
    assert u.save
  end

end
