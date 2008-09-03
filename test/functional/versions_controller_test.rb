require File.dirname(__FILE__) + '/../test_helper'

class VersionsControllerTest < ActionController::TestCase
  fixtures :versions, :logiciels, :releases

  def test_should_get_index
    %w(admin manager expert).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      assert_not_nil assigns(:versions)
    end
  end

  def test_should_create_version
    %w(admin manager).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      assert_difference('Version.count') do
        form = select_form 'main_form'
        form.version.name = "beta 2"
        form.submit
      end
      assert_redirected_to logiciel_path(assigns(:version).logiciel)
    end
  end

  def test_should_show_version
    %w(admin manager expert).each do |l|
      login l, l
      get :show, :id => Version.find(:first).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager).each do |l|
      login l, l

      get :edit, :id => Version.find(:first).id
      assert_response :success
    end
  end

  def a_test_should_update_version
    %w(admin manager).each do |l|
      login l, l

      put :update, :id => versions(:one).id, :version => { }
      assert_redirected_to version_path(assigns(:version))
    end
  end

end
