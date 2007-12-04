#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'contrats_controller'

# Re-raise errors caught by the controller.
class ContratsController; def rescue_action(e) raise e end; end

class ContratsControllerTest < Test::Unit::TestCase
  fixtures :contrats, :engagements, :clients, :severites, :typedemandes

  def setup
    @controller = ContratsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contrats)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contrat)
    assert assigns(:contrat).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contrat)
  end

  def test_create
    num_contrats = Contrat.count

    post :create, :contrat => {
      :ouverture => '2005-10-26 10:20:00',
      :cloture => '2007-10-26 10:20:00',
      :client_id => 1,
      :class_type => Contrat::Ossa.id
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_contrats + 1, Contrat.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contrat)
    assert assigns(:contrat).valid?
  end

  def test_update
    post :update, :id => 1

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Contrat.find(1)

    post :destroy, :id => 1

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contrat.find(1)
    }
  end
end
