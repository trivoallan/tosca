#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'contributions_controller'

# Re-raise errors caught by the controller.
class ContributionController; def rescue_action(e) raise e end; end

class ContributionControllerTest < Test::Unit::TestCase
  def setup
    @controller = ContributionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
