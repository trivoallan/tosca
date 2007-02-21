#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'filtres_controller'

# Re-raise errors caught by the controller.
class FiltresController; def rescue_action(e) raise e end; end

class FiltresControllerTest < Test::Unit::TestCase
  def setup
    @controller = FiltresController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
