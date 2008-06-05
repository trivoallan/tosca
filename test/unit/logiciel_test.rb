require File.dirname(__FILE__) + '/../test_helper'

class LogicielTest < Test::Unit::TestCase
  fixtures :logiciels, :competences, :images

  def test_to_strings
    check_strings Logiciel
  end

  def test_logo
    image_file = fixture_file_upload('/files/Logo_OpenOffice.org.png', 'image/svg')
    logiciel = Logiciel.new(:name => "OOo",
                            :competence_ids => [4, 8],
                            :groupe_id => 1)
    assert logiciel.save

    images(:image_00002).destroy
    t = Image.new(:image => image_file, :logiciel => logiciel)
    t.id = 2
    t.save

    software = Logiciel.find_by_name('OOo')
    assert !software.image.image.blank?
  end
end
