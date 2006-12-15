require File.dirname(__FILE__) + '/../test_helper'
require 'projets_controller'

# Re-raise errors caught by the controller.
class ProjetsController; def rescue_action(e) raise e end; end

class ProjetsControllerTest < Test::Unit::TestCase
  fixtures :projets

  def setup
    @controller = ProjetsController.new
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

    assert_not_nil assigns(:projets)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:projet)
    assert assigns(:projet).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:projet)
  end

  def test_create
    num_projets = Projet.count

    post :create, :projet => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_projets + 1, Projet.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:projet)
    assert assigns(:projet).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Projet.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Projet.find(1)
    }
  end
end
