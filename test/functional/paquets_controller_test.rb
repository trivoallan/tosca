require File.dirname(__FILE__) + '/../test_helper'
require 'versions_controller'

# Re-raise errors caught by the controller.
class PaquetsController; def rescue_action(e) raise e end; end

class PaquetsControllerTest < Test::Unit::TestCase
  fixtures :versions, :conteneurs, :distributeurs, :mainteneurs, :logiciels,
    :contracts, :clients, :credits, :components

  def setup
    @controller = PaquetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:versions)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:version)
    assert assigns(:version).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:version)
  end

  def test_create
    num_versions = Paquet.count

    post :create, :version => { :logiciel_id => 1,
           :conteneur_id => 1, :contract_id => 1, :configuration => '' }

    assert_response :redirect
    assert_redirected_to logiciel_path(assigns(:version).logiciel)

    assert_equal num_versions + 1, Paquet.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:version)
    assert assigns(:version).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => '1-openoffice-org'
  end

  def test_destroy
    assert_not_nil Paquet.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Paquet.find(1)
    }
  end
end
