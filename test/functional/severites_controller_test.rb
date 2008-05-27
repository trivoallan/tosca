require File.dirname(__FILE__) + '/../test_helper'
require 'severites_controller'

# Re-raise errors caught by the controller.
class SeveritesController; def rescue_action(e) raise e end; end

class SeveritesControllerTest < Test::Unit::TestCase
  fixtures :severites

  def setup
    @controller = SeveritesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:severites)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:severite)
    assert assigns(:severite).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:severite)
  end

  def test_create
    num_severites = Severite.count

    post :create, :severite => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_severites + 1, Severite.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:severite)
    assert assigns(:severite).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Severite.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Severite.find(1)
    }
  end
end
