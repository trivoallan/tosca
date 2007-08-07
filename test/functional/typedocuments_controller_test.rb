#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'typedocuments_controller'

# Re-raise errors caught by the controller.
class TypedocumentsController; def rescue_action(e) raise e end; end

class TypedocumentsControllerTest < Test::Unit::TestCase
  fixtures :typedocuments

  def setup
    @controller = TypedocumentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:typedocuments)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:typedocument)
    assert assigns(:typedocument).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:typedocument)
  end

  def test_create
    num_typedocuments = Typedocument.count

    post :create, :typedocument => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_typedocuments + 1, Typedocument.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:typedocument)
    assert assigns(:typedocument).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Typedocument.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Typedocument.find(1)
    }
  end
end
