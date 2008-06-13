require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditsControllerTest < ActionController::TestCase
  fixtures :credits, :contracts

  def test_should_get_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_not_nil assigns(:credits)
  end

  def test_should_get_new
    login 'admin', 'admin'
    get :new
    assert_response :success
  end

  def test_should_create_credit
    login 'admin', 'admin'
    assert_difference('Rules::Credit.count') do
      post :create, :credit => { :name => "rockin' chair" }
    end

    assert_redirected_to rules_credit_path(assigns(:credit))
  end

  def test_should_show_credit
    login 'admin', 'admin'
    get :show, :id => Rules::Credit.find(:first).id
    assert_response :success
  end

  def test_should_get_edit
    login 'admin', 'admin'
    get :edit, :id =>  Rules::Credit.find(:first).id
    assert_response :success
  end

  def test_should_update_credit
    login 'admin', 'admin'
    put :update, :id =>  Rules::Credit.find(:first).id, :credit => { }
    assert_redirected_to rules_credit_path(assigns(:credit))
  end

  def test_should_destroy_credit
    login 'admin', 'admin'
    assert_difference('Rules::Credit.count', -1) do
      delete :destroy, :id =>  Rules::Credit.find(:first).id
    end

    assert_redirected_to rules_credits_path
  end
end
