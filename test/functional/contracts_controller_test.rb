require File.dirname(__FILE__) + '/../test_helper'
require 'contracts_controller'

# Re-raise errors caught by the controller.
class ContractsController; def rescue_action(e) raise e end; end

class ContractsControllerTest < Test::Unit::TestCase
  fixtures :contracts, :commitments, :clients, :severites, :typedemandes,
    :credits, :components

  def setup
    @controller = ContractsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contracts)
  end

  def test_actives
    get :actives
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contracts)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contract)
    assert assigns(:contract).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contract)
  end

  def test_create
    num_contracts = Contract.count

    post :create, :contract => {
      :start_date => '2005-10-26 10:20:00',
      :end_date => '2007-10-26 10:20:00',
      :client_id => 1,
      :rule_type => 'Rules::Credit',
      :rule_id => 1
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_contracts + 1, Contract.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contract)
    assert assigns(:contract).valid?
  end

  def test_update
    post :update, :id => 1

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Contract.find(1)

    post :destroy, :id => 1

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contract.find(1)
    }
  end

  def test_supported_software
    get :supported_software, :id => 1
    assert_response :success
    assert_template 'supported_software'
  end

  def test_ajax_add_software
    xhr :get, :ajax_add_software, :value => 2  
    assert_response :success
    assert_template 'contracts/_software'
  end

  def test_add_software
    get :supported_software, :id => 1
    versions = Contract.find(1).versions
    assert_no_difference('versions.count') do
      form = select_form "main_form"
      form.submit
    end
    assert_difference('versions.count') do
      post :add_software, :id => 1, :software => { "-933231574" => {"software"=>"1", "paquet_id"=>"", "version"=>"xx", "active"=>"on"}, "-932877093"=>{"software"=>"1", "paquet_id"=>"1", "version"=>"x", "active"=>"on"}}
    end
  end

end
