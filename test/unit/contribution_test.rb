require File.dirname(__FILE__) + '/../test_helper'

class ContributionTest < Test::Unit::TestCase
  fixtures :contributions

  def test_to_strings
    check_strings Contribution, :contributed_on_formatted, :closed_on_formatted
  end

end
