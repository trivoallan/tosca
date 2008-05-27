require File.dirname(__FILE__) + '/../test_helper'

class EtatreversementTest < Test::Unit::TestCase
  fixtures :etatreversements

  def test_to_strings
    check_strings Etatreversement
  end
end
