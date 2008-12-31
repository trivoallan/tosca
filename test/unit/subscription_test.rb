require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  fixtures :all

  def test_strings
    check_strings Subscription
  end

end
