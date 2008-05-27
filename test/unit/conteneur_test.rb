require File.dirname(__FILE__) + '/../test_helper'

class ConteneurTest < Test::Unit::TestCase
  fixtures :conteneurs

  def test_to_strings
    check_strings Conteneur
  end
end
