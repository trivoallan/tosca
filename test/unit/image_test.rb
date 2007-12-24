#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase
  fixtures :images

  # Replace this with your real tests.
  def test_image
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    image = Image.new(:image => image_file)
    assert image.save

    # image is mandatory
    image.update_attribute(:image, nil)
    assert !image.save
    image.update_attribute(:image, '')
    assert !image.save
  end
end
