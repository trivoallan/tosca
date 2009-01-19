#
# Copyright (c) 2006-2009 Linagora
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

class PictureTest < Test::Unit::TestCase
  fixtures :images

  def test_to_strings
    check_strings Picture
  end

  def test_image
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    images(:image_00001).destroy
    image = Picture.new(:image => image_file)
    image.id = 1
    assert image.save

    image_file = fixture_file_upload('/files/logo_aliasource.jpg', 'image/jpg')
    images(:image_00003).destroy
    image = Picture.new(:image => image_file)
    image.id = 3
    assert image.save


    # the file is mandatory
    image.update_attribute(:image, nil)
    assert !image.save
    image.update_attribute(:image, '')
    assert !image.save
    image.update_attribute(:image, image_file)
    assert image.save
  end
end
