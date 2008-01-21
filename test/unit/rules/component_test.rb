require File.dirname(__FILE__) + '/../../test_helper'

class Rules::ComponentTest < ActiveSupport::TestCase
  fixtures :rules_component

  def test_to_strings
    check_strings Rules::Component
  end
end
