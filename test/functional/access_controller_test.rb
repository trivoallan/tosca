require File.dirname(__FILE__) + '/../test_helper'

class AccessControllerTest < ActionController::TestCase
  fixtures :users, :roles, :permissions_roles, :permissions

  def test_should_get_access_denied
    get :denied
    assert_response :success
  end

end
