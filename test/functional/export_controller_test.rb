require File.dirname(__FILE__) + '/../test_helper'
require 'demandes_controller'

# Re-raise errors caught by the controller.
# class DemandesController; def rescue_action(e) raise e end; end
class ExportControllerTest < Test::Unit::TestCase

   fixtures :demandes, :commentaires,
    :recipients, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :versions, :permissions, :roles,
    :permissions_roles, :contracts, :contracts_engagements, :engagements,
    :contracts_users, :users, :attachments, :contributions,
    :typedemandes


  def setup
    @controller = ExportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
  end


  def test_contributions
    get :contributions, :format => 'ods'
    assert_response :success
  end

  def test_users
    get :users, :format => 'ods'
    assert_response :success
  end

  def test_phonecalls
    get :phonecalls, :format => 'ods'
    assert_response :success
  end

  def test_requests
    get :requests, :format => 'ods'
    assert_response :success
  end

end
