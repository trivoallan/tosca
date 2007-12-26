require File.dirname(__FILE__) + '/../test_helper'

class ContributionTest < Test::Unit::TestCase
  fixtures :contributions

  def test_to_strings
    check_strings Contribution, :reverse_le_formatted
  end

end
