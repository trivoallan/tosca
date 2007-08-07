#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'competences_controller'

# Re-raise errors caught by the controller.
class CompetencesController; def rescue_action(e) raise e end; end

class CompetencesControllerTest < Test::Unit::TestCase
  fixtures :competences

  def setup
    @controller = CompetencesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
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

    assert_not_nil assigns(:competences)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:competence)
    assert assigns(:competence).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:competence)
  end

  def test_create
    num_competences = Competence.count

    post :create, :competence => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_competences + 1, Competence.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:competence)
    assert assigns(:competence).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Competence.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Competence.find(1)
    }
  end
end
