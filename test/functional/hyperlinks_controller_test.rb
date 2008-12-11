require 'test_helper'

class HyperlinksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hyperlinks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_hyperlink
    assert_difference('Hyperlink.count') do
      post :create, :hyperlink => { }
    end

    assert_redirected_to hyperlink_path(assigns(:hyperlink))
  end

  def test_should_show_hyperlink
    get :show, :id => hyperlinks(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => hyperlinks(:one).id
    assert_response :success
  end

  def test_should_update_hyperlink
    put :update, :id => hyperlinks(:one).id, :hyperlink => { }
    assert_redirected_to hyperlink_path(assigns(:hyperlink))
  end

  def test_should_destroy_hyperlink
    assert_difference('Hyperlink.count', -1) do
      delete :destroy, :id => hyperlinks(:one).id
    end

    assert_redirected_to hyperlinks_path
  end
end
