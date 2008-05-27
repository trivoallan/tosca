require File.dirname(__FILE__) + '/../test_helper'

class ChangelogTest < Test::Unit::TestCase
  fixtures :changelogs

  def test_to_strings
    check_strings Changelog
  end
end
