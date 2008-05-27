require File.dirname(__FILE__) + '/../test_helper'

class TypecontributionTest < Test::Unit::TestCase
  fixtures :typecontributions

  def test_to_strings
    check_strings Typecontribution
  end
end
