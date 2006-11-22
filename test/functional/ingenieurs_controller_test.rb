#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'ingenieurs_controller'

# Re-raise errors caught by the controller.
class IngenieursController; def rescue_action(e) raise e end; end

class IngenieursControllerTest < Test::Unit::TestCase
  fixtures :ingenieurs

  def setup
    @controller = IngenieursController.new
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

    assert_not_nil assigns(:ingenieurs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:ingenieur)
    assert assigns(:ingenieur).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:ingenieur)
  end

  def test_create
    num_ingenieurs = Ingenieur.count

    post :create, :ingenieur => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ingenieurs + 1, Ingenieur.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:ingenieur)
    assert assigns(:ingenieur).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Ingenieur.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Ingenieur.find(1)
    }
  end
end
