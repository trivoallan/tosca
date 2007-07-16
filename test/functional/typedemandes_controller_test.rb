#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'typedemandes_controller'

# Re-raise errors caught by the controller.
class TypedemandesController; def rescue_action(e) raise e end; end

class TypedemandesControllerTest < Test::Unit::TestCase
  fixtures :typedemandes

  def setup
    @controller = TypedemandesController.new
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

    assert_not_nil assigns(:typedemandes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:typedemande)
    assert assigns(:typedemande).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:typedemande)
  end

  def test_create
    num_typedemandes = Typedemande.count

    post :create, :typedemande => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_typedemandes + 1, Typedemande.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:typedemande)
    assert assigns(:typedemande).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Typedemande.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Typedemande.find(1)
    }
  end
end
