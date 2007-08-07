#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'beneficiaires_controller'

# Re-raise errors caught by the controller.
class BeneficiairesController; def rescue_action(e) raise e end; end

class BeneficiairesControllerTest < Test::Unit::TestCase
  fixtures :beneficiaires

  def setup
    @controller = BeneficiairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:beneficiaires)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:beneficiaire)
    assert assigns(:beneficiaire).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:beneficiaire)
  end

  def test_create
    num_beneficiaires = Beneficiaire.count

    post :create, :beneficiaire => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_beneficiaires + 1, Beneficiaire.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:beneficiaire)
    assert assigns(:beneficiaire).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Beneficiaire.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Beneficiaire.find(1)
    }
  end
end
