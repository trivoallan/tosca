require File.dirname(__FILE__) + '/../test_helper'

class OssaTest < Test::Unit::TestCase
  fixtures :ossas

  def test_to_strings
    check_strings Ossa
  end
end
