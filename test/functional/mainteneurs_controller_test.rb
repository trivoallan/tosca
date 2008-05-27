require File.dirname(__FILE__) + '/../test_helper'
require 'mainteneurs_controller'

# Re-raise errors caught by the controller.
class MainteneursController; def rescue_action(e) raise e end; end

class MainteneursControllerTest < Test::Unit::TestCase
  fixtures :mainteneurs

  def setup
    @controller = MainteneursController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:mainteneurs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:mainteneur)
    assert assigns(:mainteneur).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:mainteneur)
  end

  def test_create
    num_mainteneurs = Mainteneur.count

    post :create, :mainteneur => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_mainteneurs + 1, Mainteneur.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:mainteneur)
    assert assigns(:mainteneur).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Mainteneur.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Mainteneur.find(1)
    }
  end
end
