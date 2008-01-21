require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditTest < ActiveSupport::TestCase
  fixtures :rules_credit

  def test_to_strings
    check_strings Rules::Credit
  end
end
