#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'distributeurs_controller'

# Re-raise errors caught by the controller.
class DistributeursController; def rescue_action(e) raise e end; end

class DistributeursControllerTest < Test::Unit::TestCase
  fixtures :distributeurs

  def setup
    @controller = DistributeursController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:distributeurs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:distributeur)
    assert assigns(:distributeur).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:distributeur)
  end

  def test_create
    num_distributeurs = Distributeur.count

    post :create, :distributeur => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_distributeurs + 1, Distributeur.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:distributeur)
    assert assigns(:distributeur).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Distributeur.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Distributeur.find(1)
    }
  end
end
