#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'supports_controller'

# Re-raise errors caught by the controller.
class SupportsController; def rescue_action(e) raise e end; end

class SupportsControllerTest < Test::Unit::TestCase
  fixtures :supports

  def setup
    @controller = SupportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:supports)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:support)
    assert assigns(:support).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:support)
  end

  def test_create
    num_supports = Support.count

    post :create, :support => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_supports + 1, Support.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:support)
    assert assigns(:support).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Support.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Support.find(1)
    }
  end
end
