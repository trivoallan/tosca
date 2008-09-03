require File.dirname(__FILE__) + '/../test_helper'
require 'commitments_controller'

# Re-raise errors caught by the controller.
class CommitmentsController; def rescue_action(e) raise e end; end

class CommitmentsControllerTest < Test::Unit::TestCase
  fixtures :commitments, :typedemandes, :severites

  def setup
    @controller = CommitmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:commitments)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:commitment)
    assert assigns(:commitment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:commitment)
  end

  def test_create
    num_commitments = Commitment.count

    post :create, :commitment => {
      :correction => 11,
      :workaround => 0.16 # 0.16 stands for 4 hours
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_commitments + 1, Commitment.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:commitment)
    assert assigns(:commitment).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_not_nil Commitment.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Commitment.find(1)
    }
  end
end
