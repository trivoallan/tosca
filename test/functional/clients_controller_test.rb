require File.dirname(__FILE__) + '/../test_helper'

class ClientsControllerTest < ActionController::TestCase
 fixtures :clients, :contracts, :credits, :components

  def setup
    login 'admin', 'admin'
  end

  def test_stats
    get :stats
    assert_response :success
    assert_template 'stats'
    assert_not_nil assigns(:clients)
  end

  def test_index
    %w(admin manager expert).each { |l|
      login l
      get :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:clients)

      check_ajax_filter(:system_id, Socle.find(:first).id, :clients)
      # The search box cannot be checked with the helper
      xhr :get, :index, :filters => { :text => "linagora" }
      assert_response :success
    }
  end

  def test_show
    %w(admin manager expert customer viewer).each { |l|
      login l
      get :show, :id => Client.find(:first).id
      assert_response :success
      assert_template 'show'
      assert_not_nil assigns(:client)
      assert assigns(:client).valid?
    }
  end

  def test_new
    # done in test_create
  end

  def test_create
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:client)

    form = select_form "main_form"
    assert_difference('Client.count') do
      form.submit_with_name "this is an automatic test client"
    end

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to new_contract_path(:id => assigns(:client).id)
  end

  def test_edit
    # done in test_update
  end

  def test_update
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:client)
    assert assigns(:client).valid?

    form = select_form "main_form"
    form.submit_with_name "this is an automatic test client"

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => '1-Linagora'
    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end

  def test_destroy
    assert_not_nil Client.find(1)

    assert_difference('Client.count') do
      post :destroy, :id => 1
    end
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Client.find(1)
    }
  end
end
