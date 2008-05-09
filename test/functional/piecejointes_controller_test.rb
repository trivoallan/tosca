#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'piecejointes_controller'

# Re-raise errors caught by the controller.
class PiecejointesController; def rescue_action(e) raise e end; end

class PiecejointesControllerTest < Test::Unit::TestCase
  fixtures :piecejointes, :commentaires

  def setup
    @controller = PiecejointesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:piecejointes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:piecejointe)
    assert assigns(:piecejointe).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:piecejointe)
  end

  def test_create
    num_piecejointes = Piecejointe.count

    post :create, :piecejointe => {
      :file => uploaded_png("#{File.expand_path(RAILS_ROOT)}/test/fixtures/upload_document.png"),
      :commentaire => Commentaire.find(:first)
    }

    assert_response :redirect
    assert_redirected_to piecejointe_path(assigns(:piecejointe))

    assert_equal num_piecejointes + 1, Piecejointe.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:piecejointe)
    assert assigns(:piecejointe).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Piecejointe.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Piecejointe.find(1)
    }
  end
end
