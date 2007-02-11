#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'acces_controller'

# Re-raise errors caught by the controller.
class AccesController; def rescue_action(e) raise e end; end

class AccesControllerTest < Test::Unit::TestCase
  def setup
    @controller = AccesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
