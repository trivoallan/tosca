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
require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:subscriptions)
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert_template nil
  end

  def test_should_create_subscription
    post :create
    assert_response :success
    assert_template nil
  end

  def test_should_show_subscription
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_valid assigns(:subscription)
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
    assert_template nil
  end

  def test_should_update_subscription
    put :update, :id => 1, :subscription => { }
    assert_response :success
    assert_template nil
  end

  def test_should_destroy_subscription
    delete :destroy, :id => 1
    assert_response :success
    assert_template nil
  end
end
