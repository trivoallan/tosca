#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require File.dirname(__FILE__) + '/../test_helper'
require 'contributiontypes_controller'

# Re-raise errors caught by the controller.
class ContributiontypesController; def rescue_action(e) raise e end; end

class ContributiontypesControllerTest < Test::Unit::TestCase
  fixtures :contributiontypes

  def setup
    @controller = ContributiontypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contributiontypes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contributiontype)
    assert assigns(:contributiontype).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contributiontype)
  end

  def test_create
    num_contributiontypes = Contributiontype.count

    post :create, :contributiontype => { :name => "buggy", :description =>
      "a contribution in order to decrease qualitif of a FOSS" }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_contributiontypes + 1, Contributiontype.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contributiontype)
    assert assigns(:contributiontype).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Contributiontype.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contributiontype.find(1)
    }
  end
end
