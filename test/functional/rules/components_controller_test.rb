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

class Rules::ComponentsControllerTest < ActionController::TestCase
  fixtures :components, :contracts

  def test_should_get_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_not_nil assigns(:components)
  end

  def test_should_get_new
    login 'admin', 'admin'
    get :new
    assert_response :success
  end

  def test_should_create_component
    login 'admin', 'admin'
    assert_difference('Rules::Component.count') do
      post :create, :component => { :name => "rocking chair" }
    end

    assert_redirected_to rules_component_path(assigns(:component))
  end

  def test_should_show_component
    login 'admin', 'admin'
    get :show, :id =>  Rules::Component.first(:order => :id).id
    assert_response :success
  end

  def test_should_get_edit
    login 'admin', 'admin'
    get :edit, :id => Rules::Component.first(:order => :id).id
    assert_response :success
  end

  def atest_should_update_component
    login 'admin', 'admin'
    put :update, :id => rules_components(:component_00001).id, :component => { }
    assert_redirected_to rules_component_path(assigns(:component))
  end

  def test_should_destroy_component
    login 'admin', 'admin'
    assert_difference('Rules::Component.count', -1) do
      delete :destroy, :id =>  Rules::Component.first(:order => :id).id
    end

    assert_redirected_to rules_components_path
  end
end
