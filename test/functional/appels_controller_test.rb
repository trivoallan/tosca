require File.dirname(__FILE__) + '/../test_helper'
require 'appels_controller'

# Re-raise errors caught by the controller.
class AppelsController; def rescue_action(e) raise e end; end

class AppelsControllerTest < Test::Unit::TestCase
  fixtures :appels

  def setup
    @controller = AppelsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = appels(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:appels)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:appel)
    assert assigns(:appel).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:appel)
  end

  def test_create
    num_appels = Appel.count

    post :create, :appel => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_appels + 1, Appel.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:appel)
    assert assigns(:appel).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Appel.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Appel.find(@first_id)
    }
  end
end
