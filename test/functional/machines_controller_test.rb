#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'machines_controller'

# Re-raise errors caught by the controller.
class MachinesController; def rescue_action(e) raise e end; end

class MachinesControllerTest < Test::Unit::TestCase
  fixtures :machines

  def setup
    @controller = MachinesController.new
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

    assert_not_nil assigns(:machines)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:machine)
    assert assigns(:machine).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:machine)
  end

  def test_create
    num_machines = Machine.count

    post :create, :machine => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_machines + 1, Machine.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:machine)
    assert assigns(:machine).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Machine.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Machine.find(1)
    }
  end
end
