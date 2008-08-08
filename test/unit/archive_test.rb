require File.dirname(__FILE__) + '/../test_helper'

class ArchiveTest < Test::Unit::TestCase
  fixtures :attachments, :commentaires, :clients, :demandes, :recipients

#  def test_to_strings
#    check_strings Attachment
#  end
#
#  def test_scope
#    Attachment.set_scope(Client.find(:first).id)
#    Attachment.find(:all)
#    Attachment.remove_scope
#  end
#
#  def test_magick_attachments
#    attachment = fixture_file_upload('/files/mod_le_vierge_BP.doc')
#    attachments(:attachment_00001).destroy
#    options = { :file => attachment, :commentaire => commentaires(:commentaire_00001) }
#    attachment = Attachment.new(options)
#    attachment.id = 1
#    assert attachment.save
#
#    attachment = fixture_file_upload('/files/sw-html-insert-unknown-tags.diff')
#    attachments(:attachment_00002).destroy
#    options = { :file => attachment, :commentaire => commentaires(:commentaire_00002) }
#    attachment = Attachment.new(options)
#    attachment.id = 2
#    assert attachment.save
#
#    attachment = fixture_file_upload('/files/logo_linagora.gif')
#    attachments(:attachment_00003).destroy
#    options = { :file => attachment, :commentaire => commentaires(:commentaire_00003) }
#    attachment = Attachment.new(options)
#    attachment.id = 3
#    assert attachment.save
#  end

end
