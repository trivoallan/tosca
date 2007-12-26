require File.dirname(__FILE__) + '/../test_helper'

class PhonecallTest < Test::Unit::TestCase
  fixtures :phonecalls

  def test_to_strings
    check_strings Phonecall, :start_formatted, :end_formatted
  end

end
