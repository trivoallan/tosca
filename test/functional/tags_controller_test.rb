require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase
  fixtures :tags
  
  def test_should_get_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_not_nil assigns(:tags)
    end
  end

  def test_should_get_new
    %w(admin manager expert).each do |l|
      login l, l
      get :new
      assert_response :success
    end
  end

  def test_should_create_tag
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      assert_difference('Tag.count') do
        post :create, :tag => {:name => "Facile#{l}" }
      end

      assert_redirected_to tags_path
    end
  end

  def test_should_show_tag
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :show, :id => tags(:tag_00001).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager expert).each do |l|
      login l, l
      get :edit, :id => tags(:tag_00001).id
      assert_response :success
    end
  end

  def test_should_update_tag
    %w(admin manager expert).each do |l|
      login l, l
      put :update, :id => tags(:tag_00001).id, :tag => { }
      assert_redirected_to tag_path(assigns(:tag))
    end
  end

  def test_should_destroy_tag
    %w(admin).each do |l|
      login l, l
      assert_difference('Tag.count', -1) do
        delete :destroy, :id => tags(:tag_00001).id
      end

      assert_redirected_to tags_path
    end
  end
end
