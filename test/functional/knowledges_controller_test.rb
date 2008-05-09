require File.dirname(__FILE__) + '/../test_helper'

class KnowledgesControllerTest < ActionController::TestCase
  fixtures :knowledges

  def test_should_get_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_not_nil assigns(:knowledges)
  end

  def test_should_get_new
    login 'admin', 'admin'
    get :new
    assert_response :success
  end

  def test_should_create_knowledge
    login 'admin', 'admin'
    assert_difference('Knowledge.count') do
      post :create, :knowledge => { :ingenieur_id => Ingenieur.find(:first).id,
                                    :logiciel_id => Logiciel.find(:first).id,
                                    :level => 3 }
    end

    assert_redirected_to account_path(assigns(:knowledge).ingenieur.user)
  end

  def test_should_show_knowledge
    login 'admin', 'admin'
    get :show, :id => Knowledge.find(:first).id
    assert_response :success
  end

  def test_should_get_edit
    login 'admin', 'admin'
    get :edit, :id => Knowledge.find(:first).id
    assert_response :success
  end

  def test_should_update_knowledge
    login 'admin', 'admin'
    put :update, :id => Knowledge.find(:first).id, :knowledge => { }
    assert_redirected_to account_path(assigns(:knowledge).ingenieur.user)
  end

  def test_should_destroy_knowledge
    login 'admin', 'admin'
    assert_difference('Knowledge.count', -1) do
      delete :destroy, :id => Knowledge.find(:first).id
    end

    assert_redirected_to knowledges_path
  end
end
