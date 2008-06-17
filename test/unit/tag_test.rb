require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags

  def test_to_strings
    check_strings Tag 
  end
end
