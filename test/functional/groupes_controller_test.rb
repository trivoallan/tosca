#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'groupes_controller'

# Re-raise errors caught by the controller.
class GroupesController; def rescue_action(e) raise e end; end

class GroupesControllerTest < Test::Unit::TestCase
  fixtures :groupes

  def setup
    @controller = GroupesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:groupes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:groupe)
    assert assigns(:groupe).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:groupe)
  end

  def test_create
    num_groupes = Groupe.count

    post :create, :groupe => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_groupes + 1, Groupe.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:groupe)
    assert assigns(:groupe).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Groupe.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Groupe.find(1)
    }
  end
end
