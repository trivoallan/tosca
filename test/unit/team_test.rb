require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :teams, :users, :contracts
  
  #I see no tests for this model (for the momentt
  def test_to_param
    ossa = teams(:team_ossa)
    support = teams(:team_support)
    
    assert_equal ossa.to_param, "1-OSSA"
    assert_equal support.to_param, "2-Support"
  end
  
end
