#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class PiecejointeTest < Test::Unit::TestCase
  fixtures :piecejointes

  def test_presence_of_file
    p = Piecejointe.new
    assert !p.save
  end
  def test_nom
    p = Piecejointe.find 1
    assert_equal p.nom, 'SLL_FIV_mindi.odt'
  end
end
