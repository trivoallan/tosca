#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase
  fixtures :images

  def test_to_strings
    check_strings Image
  end

  # Replace this with your real tests.
  def test_image
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    images(:image_00001).destroy
    image = Image.new(:image => image_file)
    image.id = 1
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
