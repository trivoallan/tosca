#
# Copyright (c) 2006-2008 Linagora
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

class ContributionsControllerTest < ActionController::TestCase
  fixtures :contributions, :softwares, :etatreversements, :users,
    :ingenieurs, :typecontributions, :recipients

  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    check_select
  end

  def test_should_get_select
    get :select
    check_select
  end

  def check_select
    assert_response :success
    assert_template 'select'
    assert_not_nil assigns(:softwares)
  end

  def test_should_get_list
    get :list, :id => 'all'
    assert_response :success
    assert_not_nil assigns(:contributions)

    get :list, :id => 1
    assert_response :success
    assert_not_nil assigns(:contributions)

    get :list, :id => 'all', :client_id => 1
    assert_response :success
    assert_template 'list'

    get :list, :id => 1, :client_id => 1
    assert_response :success
    assert_template 'list'
  end

  def test_should_show_contribution
    get :show, :id => contributions(:contribution_0001).id
    assert_response :success
  end

  def test_should_be_able_to_update
    get :edit, :id => contributions(:contribution_0001).id
    assert_template 'edit'
    assert_response :success

    submit_with_name :contribution, 'an other short description'
    assert_response :redirect
    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_should_be_able_to_create
    get :new, :issue_id => Issue.find(:first).id,
              :software_id => Software.find(:first).id
    assert_template 'new'
    assert_response :success

    form = select_form 'main_form'
    form.contribution.name = 'a new contribution'
    form.urlreversement.valeur = 'http://www.tosca-project.net'
    form.submit

    assert_response :redirect
    assert_redirected_to contribution_path(assigns(:contribution))
  end

  def test_public_access
    logout
    test_should_get_select
    test_should_get_index
    test_should_get_list
    test_should_show_contribution
  end


end
