#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'dependances_controller'

# Re-raise errors caught by the controller.
class DependancesController; def rescue_action(e) raise e end; end

class DependancesControllerTest < Test::Unit::TestCase
  fixtures :dependances
=begin

  # This controller is not activated, it needs more love

  def setup
    @controller = DependancesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:dependances)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:dependance)
    assert assigns(:dependance).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:dependance)
  end

  def test_create
    num_dependances = Dependance.count

    post :create, :dependance => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_dependances + 1, Dependance.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:dependance)
    assert assigns(:dependance).valid?
  end

  def test_update
     post :update, {
       :id => 1,
       :dependance => {
         :paquet_id => 1,
         :name => 'kernel',
         :sens => 'un autre sens',
         :version => '1.7.18'
       }
     }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Dependance.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Dependance.find(1)
    }
  end
=end
end
