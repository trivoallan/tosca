#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'licenses_controller'

# Re-raise errors caught by the controller.
class LicensesController; def rescue_action(e) raise e end; end

class LicensesControllerTest < Test::Unit::TestCase
  fixtures :licenses

  def setup
    @controller = LicensesController.new
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

    assert_not_nil assigns(:licenses)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:license)
    assert assigns(:license).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:license)
  end

  def test_create
    num_licenses = License.count

    post :create, :license => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_licenses + 1, License.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:license)
    assert assigns(:license).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil License.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      License.find(1)
    }
  end
end
