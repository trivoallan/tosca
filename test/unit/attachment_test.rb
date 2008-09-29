#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments, :comments, :clients, :issues, :recipients

  def test_to_strings
    check_strings Attachment
  end

  def test_scope
    Attachment.set_scope(Client.find(:first).id)
    Attachment.find(:all)
    Attachment.remove_scope
  end

  def test_magick_attachments
    attachment = fixture_file_upload('/files/mod_le_vierge_BP.doc')
    attachments(:attachment_00001).destroy
    options = { :file => attachment, :comment => comments(:comment_00001) }
    attachment = Attachment.new(options)
    attachment.id = 1
    assert attachment.save

    attachment = fixture_file_upload('/files/sw-html-insert-unknown-tags.diff')
    attachments(:attachment_00002).destroy
    options = { :file => attachment, :comment => comments(:comment_00002) }
    attachment = Attachment.new(options)
    attachment.id = 2
    assert attachment.save

    attachment = fixture_file_upload('/files/logo_linagora.gif')
    attachments(:attachment_00003).destroy
    options = { :file => attachment, :comment => comments(:comment_00003) }
    attachment = Attachment.new(options)
    attachment.id = 3
    assert attachment.save
  end

end
