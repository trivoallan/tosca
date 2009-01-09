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
require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditsControllerTest < ActionController::TestCase
  fixtures :credits, :contracts

  def test_should_get_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_not_nil assigns(:credits)
  end

  def test_should_get_new
    login 'admin', 'admin'
    get :new
    assert_response :success
  end

  def test_should_create_credit
    login 'admin', 'admin'
    assert_difference('Rules::Credit.count') do
      post :create, :credit => { :name => "rockin' chair" }
    end

    assert_redirected_to rules_credit_path(assigns(:credit))
  end

  def test_should_show_credit
    login 'admin', 'admin'
    get :show, :id => Rules::Credit.first(:order => :id).id
    assert_response :success
  end

  def test_should_get_edit
    login 'admin', 'admin'
    get :edit, :id =>  Rules::Credit.first(:order => :id).id
    assert_response :success
  end

  def test_should_update_credit
    login 'admin', 'admin'
    put :update, :id =>  Rules::Credit.first(:order => :id).id, :credit => { }
    assert_redirected_to rules_credit_path(assigns(:credit))
  end

  def test_should_destroy_credit
    login 'admin', 'admin'
    assert_difference('Rules::Credit.count', -1) do
      delete :destroy, :id =>  Rules::Credit.first(:order => :id).id
    end

    assert_redirected_to rules_credits_path
  end
end
