require File.dirname(__FILE__) + '/../test_helper'

class TypeurlTest < Test::Unit::TestCase
  fixtures :typeurls

  def test_to_strings
    check_strings Typeurl
  end

end
