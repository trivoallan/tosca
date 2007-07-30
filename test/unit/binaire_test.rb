#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class BinaireTest < Test::Unit::TestCase
  fixtures :binaires, :paquets

  def test_to_s
    bin = Binaire.find 1
    assert_equal bin.to_s, 'cups-1.1.17-13.3.6'
  end
end
