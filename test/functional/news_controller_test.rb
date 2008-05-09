require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < Test::Unit::TestCase
  fixtures :news

  def test_nothing
  end
=begin

  # It needs more love

  def setup
    @controller = NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

#   @first_id = news(:first).id
    login 'admin', 'admin'
    @first_id = New.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:news)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:new)
    assert assigns(:new).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:new)
  end

  def test_create
    num_news = New.count

    post :create, :new => {
      :logiciel_id => 1,
      :ingenieur_id => 1
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_news + 1, New.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:new)
    assert assigns(:new).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      New.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      New.find(@first_id)
    }
  end

  def test_newsletter
    get :newsletter

    assert_response :success
  end
=end

end
