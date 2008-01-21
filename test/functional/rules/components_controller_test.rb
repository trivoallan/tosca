require File.dirname(__FILE__) + '/../../test_helper'

class Rules::ComponentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rules_components)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_component
    assert_difference('Rules::Component.count') do
      post :create, :component => { }
    end

    assert_redirected_to component_path(assigns(:component))
  end

  def test_should_show_component
    get :show, :id => rules_components(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => rules_components(:one).id
    assert_response :success
  end

  def test_should_update_component
    put :update, :id => rules_components(:one).id, :component => { }
    assert_redirected_to component_path(assigns(:component))
  end

  def test_should_destroy_component
    assert_difference('Rules::Component.count', -1) do
      delete :destroy, :id => rules_components(:one).id
    end

    assert_redirected_to rules_components_path
  end
end
