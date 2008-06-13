require File.dirname(__FILE__) + '/../test_helper'
require 'binaires_controller'

# Re-raise errors caught by the controller.
class BinairesController; def rescue_action(e) raise e end; end

class BinairesControllerTest < Test::Unit::TestCase
  fixtures :binaires, :paquets, :logiciels, :contracts,
    :clients, :socles, :arches

  def setup
    @controller = BinairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def atest_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:binaires)
  end

  def atest_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def atest_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:binaire)
  end

  def test_create
    num_binaires = Binaire.count

    post :create, :binaire => { :paquet_id => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'paquets'
    assert flash.has_key?(:notice)

    assert_equal num_binaires + 1, Binaire.count
  end

  def atest_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def atest_update
    post :update, :id => 1

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def atest_destroy
    assert_not_nil Binaire.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Binaire.find(1)
    }
  end
end
