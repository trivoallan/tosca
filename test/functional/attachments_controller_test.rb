require File.dirname(__FILE__) + '/../test_helper'
require 'attachments_controller'

# Re-raise errors caught by the controller.
class AttachmentsController; def rescue_action(e) raise e end; end

class AttachmentsControllerTest < Test::Unit::TestCase
  fixtures :attachments, :commentaires

  def setup
    @controller = AttachmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:attachments)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:attachment)
    assert assigns(:attachment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:attachment)
  end

  def test_create
    num_attachments = Attachment.count

    post :create, :attachment => {
      :file => uploaded_png("#{File.expand_path(RAILS_ROOT)}/test/fixtures/upload_document.png"),
      :commentaire => Commentaire.find(:first)
    }

    assert_response :redirect
    assert_redirected_to attachment_path(assigns(:attachment))

    assert_equal num_attachments + 1, Attachment.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:attachment)
    assert assigns(:attachment).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Attachment.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Attachment.find(1)
    }
  end
end
