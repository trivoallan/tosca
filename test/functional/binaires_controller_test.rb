#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'binaires_controller'

# Re-raise errors caught by the controller.
class BinairesController; def rescue_action(e) raise e end; end

class BinairesControllerTest < Test::Unit::TestCase
  fixtures :binaires, :paquets, :logiciels, :contrats,
    :clients, :socles, :arches

  def setup
    @controller = BinairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:binaires)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:binaire)
  end

  def test_create
    num_binaires = Binaire.count

    post :create, :binaire => { :paquet_id => 1 }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :controller => 'paquets'

    assert_equal num_binaires + 1, Binaire.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:binaire)
    assert assigns(:binaire).valid?
  end

  def test_update
    post :update, :id => 1

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Binaire.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Binaire.find(1)
    }
  end
end
