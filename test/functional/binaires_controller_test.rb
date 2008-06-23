require File.dirname(__FILE__) + '/../test_helper'

class BinairesControllerTest < ActionController::TestCase
  fixtures :binaires, :paquets, :logiciels, :contracts,
    :clients, :socles, :arches

  def setup
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:binaires)
  end

  def test_show
    get :show, :id => Binaire.find(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:binaire)
  end

  def test_create
    get :new

    assert_difference('Binaire.count') do
      submit_with_name :binaire, "a new name"
    end

    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'paquets'
    assert flash.has_key?(:notice)
  end

  def test_edit
    get :edit, :id => Binaire.find(:first).id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def test_update
    get :edit, :id => Binaire.find(:first).id

    submit_with_name :binaire, "an updated name"

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def test_destroy
    assert_not_nil Binaire.find(:first)

    assert_difference("Binaire.count", -1) do
      delete :destroy, :id => Binaire.find(:first).id
    end

    assert_response :redirect
    assert_redirected_to bienvenue_path
  end
end
