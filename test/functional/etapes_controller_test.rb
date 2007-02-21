#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'etapes_controller'

# Re-raise errors caught by the controller.
class EtapesController; def rescue_action(e) raise e end; end

class EtapesControllerTest < Test::Unit::TestCase
  fixtures :etapes

  def setup
    @controller = EtapesController.new
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

    assert_not_nil assigns(:etapes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:etape)
    assert assigns(:etape).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:etape)
  end

  def test_create
    num_etapes = Etape.count

    post :create, :etape => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_etapes + 1, Etape.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:etape)
    assert assigns(:etape).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Etape.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Etape.find(1)
    }
  end
end
