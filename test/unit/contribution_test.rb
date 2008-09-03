require File.dirname(__FILE__) + '/../test_helper'

class ContributionTest < Test::Unit::TestCase
  fixtures :contributions

  def test_to_strings
    check_strings Contribution, :contributed_on_formatted, :summary
  end

  def test_content_columns
    assert !Contribution.content_columns.empty?
  end

  def test_fragments
    assert !Contribution.find(:first).fragments.empty?
  end

  def test_delay
    delay = contributions(:contribution_0001).delay
    assert_instance_of Rational, delay
    # this one does not have a delay.
    delay = contributions(:contribution_0003).delay
    assert_instance_of Fixnum, delay
  end

  # This one cannot be included in "test_to_strings" since some contributions
  # does not have a closed_on date.
  def test_closed_on
    text = contributions(:contribution_0001).closed_on_formatted
    assert !text.blank?
  end
end
