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
    get :show, :id => Permission.first(:order => :id).id

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
    get :edit, :id => Permission.first(:order => :id).id
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
    perm = Permission.first(:order => :id)
    assert_difference('Permission.count', -1) do
      post :destroy, :id =>  perm.id
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
    perm.save # we restore it in order to keep a usable test db
  end
end
