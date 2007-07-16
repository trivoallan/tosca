#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'jourferies_controller'

# Re-raise errors caught by the controller.
class JourferiesController; def rescue_action(e) raise e end; end

class JourferiesControllerTest < Test::Unit::TestCase
  fixtures :jourferies

  def setup
    @controller = JourferiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:jourferies)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:jourferie)
    assert assigns(:jourferie).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:jourferie)
  end

  def test_create
    num_jourferies = Jourferie.count

    post :create, :jourferie => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_jourferies + 1, Jourferie.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:jourferie)
    assert assigns(:jourferie).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Jourferie.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Jourferie.find(1)
    }
  end
end
