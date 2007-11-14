#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'documents_controller'

# Re-raise errors caught by the controller.
class DocumentsController; def rescue_action(e) raise e end; end

class DocumentsControllerTest < Test::Unit::TestCase
  fixtures :documents, :typedocuments, :clients

  def setup
    @controller = DocumentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'select'
  end

  def test_list
    get :list, :id => 1

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:documents)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:document)
    assert assigns(:document).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:document)
  end

  def test_create
    num_documents = Document.count

    post :create, :document => {
      :version => 1,
      :created_on => "2006-09-05 18:08:49",
      :updated_on => "2007-07-26 11:35:58",
      :client_id => 1,
      :description => "Etude réalisée pour SI2 dans le cadre de\r\nl'évaluation des solutions Open Source comme alternative à Lotus Notes",
      :fichier => uploaded_png("#{File.expand_path(RAILS_ROOT)}/test/fixtures/upload_document.png"),
      :titre => "Etude Migration Lotus (SI2)",
      :user_id => 1 ,
      :date_delivery => nil,
      :typedocument_id => 1
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'select'

    assert_equal num_documents + 1, Document.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:document)
    assert assigns(:document).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', 
      :id => '1-Etude-Migration-Lotus-SI2-'
  end

  def test_destroy
    assert_not_nil Document.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Document.find(1)
    }
  end
end
