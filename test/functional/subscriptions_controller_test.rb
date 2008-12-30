require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:subscriptions)
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert_template nil
  end

  def test_should_create_subscription
    post :create
    assert_response :success
    assert_template nil
  end

  def test_should_show_subscription
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_valid assigns(:subscription)
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
    assert_template nil
  end

  def test_should_update_subscription
    put :update, :id => 1, :subscription => { }
    assert_response :success
    assert_template nil
  end

  def test_should_destroy_subscription
    delete :destroy, :id => 1
    assert_response :success
    assert_template nil
  end
end
