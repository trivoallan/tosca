require File.dirname(__FILE__) + '/../test_helper'

class PermissionsControllerTest < ActionController::TestCase
  fixtures :permissions

  def setup
    login 'admin', 'admin'
  end

  def test_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:permissions)
  end

  def test_show
    login 'admin', 'admin'
    get :show, :id => Permission.find(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:permission)
    assert assigns(:permission).valid?
  end

  def test_new_and_create
    login 'admin', 'admin'
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:permission)

    assert_difference('Permission.count') do
      form = select_form 'main_form'
      form.permission.name = "new_perm"
      form.submit
    end
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_edit_and_update
    login 'admin', 'admin'
    get :edit, :id => Permission.find(:first).id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:permission)
    assert assigns(:permission).valid?

    form = select_form 'main_form'
    form.permission.info = "info_perm"
    form.submit

    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    perm = Permission.find(:first)
    assert_difference('Permission.count', -1) do
      post :destroy, :id =>  perm.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
    perm.save # we restore it in order to keep a usable test db
  end
end
