#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class PiecejointeTest < Test::Unit::TestCase
  fixtures :piecejointes

  def test_to_strings
    check_strings Piecejointe
  end

  def test_magick_attachments
    attachment = fixture_file_upload('/files/sw-html-insert-unknown-tags.diff')
    piecejointes(:piecejointe_00001).destroy
    piecejointe = Piecejointe.new(:file => attachment)
    piecejointe.id = 1
    assert piecejointe.save

    attachment = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    piecejointes(:piecejointe_00002).destroy
    piecejointe = Piecejointe.new(:file => attachment)
    piecejointe.id = 2
    assert piecejointe.save
  end

end
