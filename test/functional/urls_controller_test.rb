require File.dirname(__FILE__) + '/../test_helper'
require 'urls_controller'

# Re-raise errors caught by the controller.
class UrlsController; def rescue_action(e) raise e end; end

class UrlsControllerTest < Test::Unit::TestCase

  fixtures :urls, :logiciels

  def setup
    @controller = UrlsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:urls)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:url)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:url)
  end

  def test_create
    num_urls = Url.count

    post :create, :urls => {
      :valeur => 'une valeur',
      :logiciel_id => 1,
      :typeurl_id => 1,
      :resource_type => "Logiciel"
    }

    post :create, :urls => {
      :valeur => 'une valeur',
      :contribution_id => 1,
      :resource_type => "Reversement"
    }

    #TODO assert fails
    #assert_equal num_urls + 2, Url.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:url)
  end

  def test_update
    post :update, :id => 1, :resource_type => "Logiciel"
    assert_redirected_to :action => 'show', :id => '1-ANT'
  end

  def test_destroy
    assert_not_nil Url.find(1)

    post :destroy, :id => 1
    assert_response :redirect

    assert_raise(ActiveRecord::RecordNotFound) {
      Url.find(1)
    }
  end

end
