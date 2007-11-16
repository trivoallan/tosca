require File.dirname(__FILE__) + '/../test_helper'

class ContributionTest < Test::Unit::TestCase
  fixtures :contributions

  # Replace this with your real tests.
  def test_reverse_le
    c = Contribution.new(
      :name => "averylongname", 
      :logiciel_id => 2 
    )
    assert_equal c.reverse_le_formatted, '' 
  end



end
