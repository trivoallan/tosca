require File.dirname(__FILE__) + '/../test_helper'

class GroupeTest < Test::Unit::TestCase
  fixtures :groupes

  def test_to_strings
    check_strings Groupe
  end

end
