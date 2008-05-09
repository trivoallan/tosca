#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'urllogiciels_controller'

# Re-raise errors caught by the controller.
class UrllogicielsController; def rescue_action(e) raise e end; end

class UrllogicielsControllerTest < Test::Unit::TestCase
  fixtures :urllogiciels, :logiciels

  def setup
    @controller = UrllogicielsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:urllogiciels)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:urllogiciel)
    assert assigns(:urllogiciel).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:urllogiciel)
  end

  def test_create
    num_urllogiciels = Urllogiciel.count

    post :create, :urllogiciel => {
      :logiciel_id => 1,
      :typeurl_id => 1,
      :valeur => "www.disney.fr"

    }

    assert_response :redirect
    assert_redirected_to logiciel_path(assigns(:urllogiciel).logiciel)

    assert_equal num_urllogiciels + 1, Urllogiciel.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:urllogiciel)
    assert assigns(:urllogiciel).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to logiciel_path(assigns(:urllogiciel).logiciel)
  end

  def test_destroy
    url = Urllogiciel.find(1)
    assert_not_nil url

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to logiciel_path(url.logiciel)

    assert_raise(ActiveRecord::RecordNotFound) {
      Urllogiciel.find(1)
    }
  end
end
