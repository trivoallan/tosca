require File.dirname(__FILE__) + '/../test_helper'

class ContributionsControllerTest < ActionController::TestCase
  fixtures :contributions, :logiciels, :etatreversements, :users,
    :ingenieurs, :typecontributions, :beneficiaires

  def setup
    @controller = ContributionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    check_select
  end

  def test_should_get_select
    get :select
    check_select
  end

  def check_select
    assert_response :success
    assert_template 'select'
    assert_not_nil assigns(:logiciels)
  end

  def test_should_get_list
    get :list, :id => 'all'
    assert_response :success
    assert_not_nil assigns(:contributions)

    get :list, :id => 1
    assert_response :success
    assert_not_nil assigns(:contributions)
    
    get :list, :id => 'all', :client_id => 1
    assert_response :success
    assert_template 'list'
  end

  def test_should_show_contribution
    get :show, :id => contributions(:contribution_00001).id
    assert_response :success
  end

  def test_should_be_able_to_update
    login 'admin', 'admin' # setup method is broken as of Rails 2.0.2 ...

    get :edit, :id => contributions(:contribution_00001).id
    assert_template 'edit'
    assert_response :success

    submit_with_name :contribution, 'an other short description'
    assert_response :redirect
    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_should_be_able_to_create
    login 'admin', 'admin' # setup method is broken as of Rails 2.0.2 ...

    get :edit, :id => contributions(:contribution_00001).id
    assert_template 'edit'
    assert_response :success

    submit_with_name :contribution, 'an other short description'
    assert_response :redirect
    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_public_access
    logout
    test_should_get_select
    test_should_get_index
    test_should_get_list
    test_should_show_contribution
  end


end
