#####################################################
#
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class PaquetTest < Test::Unit::TestCase
  fixtures :paquets, :typedemandes, :severites, :contracts_engagements,
    :engagements, :changelogs, :dependances, :binaires

  def test_to_strings
    check_strings Paquet
  end

  def test_destroy
    Paquet.find(:all).each { |p|
      p.destroy
      assert Binaire.find_all_by_paquet_id(p.id).empty?
      assert Changelog.find_all_by_paquet_id(p.id).empty?
      assert Dependance.find_all_by_paquet_id(p.id).empty?
    }
  end

=begin
  TODO
  def test_contournement
    p = Paquet.find 1
    assert_equal p.contournement(2,1), 0.16
  end

  def test_correction
    p = Paquet.find 1
    assert_equal p.correction(2,1), 11
  end
=end

end
