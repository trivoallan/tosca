#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class PaquetTest < Test::Unit::TestCase
  fixtures :paquets

  def test_to_param
    p = Paquet.find 1
    assert_equal p.to_param, '1-cups'
  end
  def test_to_s
    p = Paquet.find 1
    assert_equal p.to_s, 'rpm cups-1.1.17-13.3.6'
    p = Paquet.find 2
    assert_equal p.to_s, 'unknown_name vim-1.7-13.3.6'
  end

  #TODO pas moyen de tester contournement ...
  # je verrais après
# def test_contournement
#   p = Paquet.find 1
#   assert_equal p.contournement(2,1), 'rr'
# end
end
