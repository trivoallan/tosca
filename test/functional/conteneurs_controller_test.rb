#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'conteneurs_controller'

# Re-raise errors caught by the controller.
class ConteneursController; def rescue_action(e) raise e end; end

class ConteneursControllerTest < Test::Unit::TestCase
  fixtures :conteneurs

  def setup
    @controller = ConteneursController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:conteneurs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:conteneur)
    assert assigns(:conteneur).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:conteneur)
  end

  def test_create
    num_conteneurs = Conteneur.count

    post :create, :conteneur => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_conteneurs + 1, Conteneur.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:conteneur)
    assert assigns(:conteneur).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Conteneur.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Conteneur.find(1)
    }
  end
end
