#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'logiciels_controller'

# Re-raise errors caught by the controller.
class LogicielsController; def rescue_action(e) raise e end; end

class LogicielsControllerTest < Test::Unit::TestCase
  fixtures :logiciels, :competences

  def setup
    @controller = LogicielsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:logiciels)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:logiciel)
    assert assigns(:logiciel)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:logiciel)
  end

  def test_create
    num_logiciels = Logiciel.count

    post :create, :logiciel => {
      :nom=> 'ANT',
      :groupe_id=> 4,
      :referent=> 'ant',
      :description=> 'un bon logiciel.',
      :resume=> 'Outil de compilation pour java',
      :license_id=> 2,
      :image_id => 1,
      :competence_ids => [1]
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_logiciels + 1, Logiciel.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:logiciel)
    assert assigns(:logiciel)
  end

  def test_update
    options = {
        :nom => 'ANT',
        :groupe_id=> 4,
        :referent=> 'ant',
        :description=> 'un bon logiciel.',
        :resume=> 'Outil de compilation pour java',
        :license_id=> 2,
        :image_id => 1,
        :competence_ids => [1]
    }
    post :update, { :id => 1, :logiciel => options }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_not_nil Logiciel.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Logiciel.find(1)
    }
  end
end
