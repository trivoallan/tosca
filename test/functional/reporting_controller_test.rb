#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'reporting_controller'

# Re-raise errors caught by the controller.
class ReportingController; def rescue_action(e) raise e end; end

class ReportingControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReportingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
