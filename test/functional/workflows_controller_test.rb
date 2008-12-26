require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_template nil
  end

  def test_should_get_new
    get :new, :issuetype_id => 1
    assert_response :success
    # TODO : test create
  end

  def test_should_create_workflow
=begin
    assert_difference('Workflow.count') do
      post :create, :workflow => { }
    end

    assert_redirected_to workflow_path(assigns(:workflow))
=end
  end

  def test_should_show_workflow
    get :show, :id => 1
    assert_response :success
    assert_template nil
  end

  def test_should_get_edit
    get :edit, :id => Workflow.first.id
    assert_response :success
    # TODO : test update
  end

  def test_should_update_workflow
=begin
    put :update, :id => workflows(:one).id, :workflow => { }
    assert_redirected_to workflow_path(assigns(:workflow))
=end
  end

  def test_should_destroy_workflow
    workflow = Workflow.first
    assert_difference('Workflow.count', -1) do
      delete :destroy, :id => workflow.id
    end

    assert_redirected_to issuetype_path(workflow.issuetype)
  end
end
