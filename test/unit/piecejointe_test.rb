require File.dirname(__FILE__) + '/../test_helper'

class PiecejointeTest < Test::Unit::TestCase
  fixtures :piecejointes, :commentaires

  def test_to_strings
    check_strings Piecejointe
  end

  def test_magick_attachments
    attachment = fixture_file_upload('/files/mod_le_vierge_BP.doc')
    piecejointes(:piecejointe_00001).destroy
    options = { :file => attachment, :commentaire => commentaires(:commentaire_00001) }
    piecejointe = Piecejointe.new(options)
    piecejointe.id = 1
    assert piecejointe.save

    attachment = fixture_file_upload('/files/sw-html-insert-unknown-tags.diff')
    piecejointes(:piecejointe_00002).destroy
    options = { :file => attachment, :commentaire => commentaires(:commentaire_00002) }
    piecejointe = Piecejointe.new(options)
    piecejointe.id = 2
    assert piecejointe.save

    attachment = fixture_file_upload('/files/logo_linagora.gif')
    piecejointes(:piecejointe_00003).destroy
    options = { :file => attachment, :commentaire => commentaires(:commentaire_00003) }
    piecejointe = Piecejointe.new(options)
    piecejointe.id = 3
    assert piecejointe.save
  end

end
