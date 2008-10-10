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

class SoftwareTest < Test::Unit::TestCase
  fixtures :softwares, :competences, :images, :contracts

  def test_to_strings
    check_strings Software
  end

  def test_scope
    Software.set_public_scope
    Software.remove_scope
  end

  def test_arrays
    check_arrays Software
  end

  def test_and_upload_logos
    upload_logo('/files/Logo_OpenOffice.org.png', 'image/svg', 2)
    upload_logo('/files/logo_firefox.gif', 'image/gif', 4)
    upload_logo('/files/logo_cvs.gif', 'image/gif', 5)

    assert !@software.image.image.blank?
  end

  # We need to upload files in order to have working logo in test environment.
  def upload_logo(path, mimetype, id)
    @software ||= Software.find(:first)
    image_file = fixture_file_upload(path, mimetype)
    Image.find(id).destroy
    image = Image.new(:image => image_file, :software => @software)
    image.id = id
    image.save!
  end
end
