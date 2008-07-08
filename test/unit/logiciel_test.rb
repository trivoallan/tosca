require File.dirname(__FILE__) + '/../test_helper'

class LogicielTest < Test::Unit::TestCase
  fixtures :logiciels, :competences, :images

  def test_to_strings
    check_strings Logiciel
  end

  def test_and_upload_logos
    upload_logo('/files/Logo_OpenOffice.org.png', 'image/svg', 2)
    upload_logo('/files/logo_firefox.gif', 'image/gif', 4)
    upload_logo('/files/logo_cvs.gif', 'image/gif', 5)

    assert !@software.image.image.blank?
  end

  # We need to upload files in order to have working logo in test environment.
  def upload_logo(path, mimetype, id)
    @software ||= Logiciel.find(:first)
    image_file = fixture_file_upload(path, mimetype)
    Image.find(id).destroy
    image = Image.new(:image => image_file, :logiciel => @software)
    image.id = id
    image.save!
  end
end
