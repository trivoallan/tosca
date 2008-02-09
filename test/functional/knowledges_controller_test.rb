require File.dirname(__FILE__) + '/../test_helper'

class KnowledgesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:knowledges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_knowledge
    assert_difference('Knowledge.count') do
      post :create, :knowledge => { }
    end

    assert_redirected_to knowledge_path(assigns(:knowledge))
  end

  def test_should_show_knowledge
    get :show, :id => knowledges(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => knowledges(:one).id
    assert_response :success
  end

  def test_should_update_knowledge
    put :update, :id => knowledges(:one).id, :knowledge => { }
    assert_redirected_to knowledge_path(assigns(:knowledge))
  end

  def test_should_destroy_knowledge
    assert_difference('Knowledge.count', -1) do
      delete :destroy, :id => knowledges(:one).id
    end

    assert_redirected_to knowledges_path
  end
end
