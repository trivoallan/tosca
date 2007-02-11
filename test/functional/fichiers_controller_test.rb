#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'fichiers_controller'

# Re-raise errors caught by the controller.
class FichiersController; def rescue_action(e) raise e end; end

class FichiersControllerTest < Test::Unit::TestCase
  fixtures :fichiers

  def setup
    @controller = FichiersController.new
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

    assert_not_nil assigns(:fichiers)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:fichier)
    assert assigns(:fichier).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:fichier)
  end

  def test_create
    num_fichiers = Fichier.count

    post :create, :fichier => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_fichiers + 1, Fichier.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:fichier)
    assert assigns(:fichier).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Fichier.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Fichier.find(1)
    }
  end
end
