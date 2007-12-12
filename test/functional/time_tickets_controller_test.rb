require File.dirname(__FILE__) + '/../test_helper'
require 'time_tickets_controller'

# Re-raise errors caught by the controller.
class TimeTicketsController; def rescue_action(e) raise e end; end

class TimeTicketsControllerTest < Test::Unit::TestCase
  fixtures :time_tickets

  def setup
    @controller = TimeTicketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
    @first_id = time_tickets(:time_ticket_00001).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:time_tickets)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:time_ticket)
    assert assigns(:time_ticket).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:time_ticket)
  end

  def test_create
    num_time_tickets = TimeTicket.count

    post :create, :time_ticket => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_time_tickets + 1, TimeTicket.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:time_ticket)
    assert assigns(:time_ticket).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      TimeTicket.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      TimeTicket.find(@first_id)
    }
  end
end
