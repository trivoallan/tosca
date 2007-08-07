#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'arches_controller'

# Re-raise errors caught by the controller.
class ArchesController; def rescue_action(e) raise e end; end

class ArchesControllerTest < Test::Unit::TestCase
  fixtures :arches

  def setup
    @controller = ArchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:arches)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:arch)
    assert assigns(:arch).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:arch)
  end

  def test_create
    num_arches = Arch.count

    post :create, :arch => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_arches + 1, Arch.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:arch)
    assert assigns(:arch).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Arch.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Arch.find(1)
    }
  end
end
