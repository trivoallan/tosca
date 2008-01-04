require File.dirname(__FILE__) + '/../test_helper'

class ElapsedTest < ActiveSupport::TestCase
  fixtures :elapseds


  def test_to_strings
    check_strings Elapsed
  end

end
