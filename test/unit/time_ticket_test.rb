require File.dirname(__FILE__) + '/../test_helper'

class TimeTicketTest < Test::Unit::TestCase
  fixtures :time_tickets

  # Replace this with your real tests.
  def test_to_strings
    check_strings TimeTicket
  end
end
