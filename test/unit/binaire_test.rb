#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class BinaireTest < Test::Unit::TestCase
  fixtures :binaires, :paquets

  def test_to_strings
    check_strings Binaire
  end

end
