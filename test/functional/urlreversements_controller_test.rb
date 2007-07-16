#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'urlreversements_controller'

# Re-raise errors caught by the controller.
class UrlreversementsController; def rescue_action(e) raise e end; end

class UrlreversementsControllerTest < Test::Unit::TestCase
  fixtures :urlreversements

  def setup
    @controller = UrlreversementsController.new
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

    assert_not_nil assigns(:urlreversements)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:urlreversement)
    assert assigns(:urlreversement).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:urlreversement)
  end

  def test_create
    num_urlreversements = Urlreversement.count

    post :create, :urlreversement => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_urlreversements + 1, Urlreversement.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:urlreversement)
    assert assigns(:urlreversement).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Urlreversement.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Urlreversement.find(1)
    }
  end
end
