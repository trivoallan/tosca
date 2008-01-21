require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rules_credits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_credit
    assert_difference('Rules::Credit.count') do
      post :create, :credit => { }
    end

    assert_redirected_to credit_path(assigns(:credit))
  end

  def test_should_show_credit
    get :show, :id => rules_credits(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rules_credits(:one).id
    assert_response :success
  end

  def test_should_update_credit
    put :update, :id => rules_credits(:one).id, :credit => { }
    assert_redirected_to credit_path(assigns(:credit))
  end

  def test_should_destroy_credit
    assert_difference('Rules::Credit.count', -1) do
      delete :destroy, :id => rules_credits(:one).id
    end

    assert_redirected_to rules_credits_path
  end
end
