#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class AccessControllerTest < ActionController::TestCase

  def test_should_get_access_denied
    get :denied
    assert_response :success
  end

end
