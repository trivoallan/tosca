#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'typeurls_controller'

# Re-raise errors caught by the controller.
class TypeurlsController; def rescue_action(e) raise e end; end

class TypeurlsControllerTest < Test::Unit::TestCase
  fixtures :typeurls

  def setup
    @controller = TypeurlsController.new
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

    assert_not_nil assigns(:typeurls)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:typeurl)
    assert assigns(:typeurl).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:typeurl)
  end

  def test_create
    num_typeurls = Typeurl.count

    post :create, :typeurl => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_typeurls + 1, Typeurl.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:typeurl)
    assert assigns(:typeurl).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Typeurl.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Typeurl.find(1)
    }
  end
end
