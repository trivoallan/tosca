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

class KnowledgesControllerTest < ActionController::TestCase
  fixtures :knowledges

  def test_should_get_index
    login 'admin', 'admin'
    get :index
    assert_response :success
    assert_not_nil assigns(:knowledges)
  end

  def test_should_get_new
    login 'admin', 'admin'
    get :new
    assert_response :success
  end

  def test_should_create_knowledge
    login 'admin', 'admin'
    assert_difference('Knowledge.count') do
      post :create, :knowledge => { :engineer_id => User.first(:order => :id).id,
                                    :software_id => Software.first(:order => :id).id,
                                    :level => 3 }
    end

    assert_redirected_to account_path(assigns(:knowledge).engineer)
  end

  def test_should_show_knowledge
    login 'admin', 'admin'
    get :show, :id => Knowledge.first(:order => :id).id
    assert_response :success
  end

  def test_should_get_edit
    login 'admin', 'admin'
    get :edit, :id => Knowledge.first(:order => :id).id
    assert_response :success
  end

  def test_should_update_knowledge
    login 'admin', 'admin'
    put :update, :id => Knowledge.first(:order => :id).id, :knowledge => { }
    assert_redirected_to account_path(assigns(:knowledge).engineer)
  end

  def test_should_destroy_knowledge
    login 'admin', 'admin'
    assert_difference('Knowledge.count', -1) do
      delete :destroy, :id => Knowledge.first(:order => :id).id
    end

    assert_redirected_to knowledges_path
  end
end
