#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class FichierTest < Test::Unit::TestCase
  fixtures :fichiers

  def test_to_strings
    check_strings Fichier
  end
end
