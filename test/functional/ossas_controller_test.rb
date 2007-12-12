require File.dirname(__FILE__) + '/../test_helper'
require 'ossas_controller'

# Re-raise errors caught by the controller.
class OssasController; def rescue_action(e) raise e end; end

class OssasControllerTest < Test::Unit::TestCase
  fixtures :ossas

  def setup
    @controller = OssasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
    @first_id = ossas(:ossa_00001).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:ossas)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:ossa)
    assert assigns(:ossa).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:ossa)
  end

  def test_create
    num_ossas = Ossa.count

    post :create, :ossa => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_ossas + 1, Ossa.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:ossa)
    assert assigns(:ossa).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_nothing_raised {
      Ossa.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Ossa.find(@first_id)
    }
  end
end
