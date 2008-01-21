require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditTest < ActiveSupport::TestCase
  fixtures :credits

  def test_to_strings
    check_strings Rules::Credit
  end
end
