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

class TeamsControllerTest < ActionController::TestCase

  fixtures :all

  def test_should_get_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      assert_not_nil assigns(:teams)
    end
  end

  def test_should_create_team
    %w(admin manager).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      assert_difference('Team.count') do
        form = select_form 'form_team'
        form.team.name = "TestTeam#{l}"
        form.team.motto = "TestMotto"
        form.team.contact_id = 1
        form.submit
      end
      assert_redirected_to team_path(assigns(:team))
    end
  end

  def test_should_show_team
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :show, :id => teams(:team_ossa).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager).each do |l|
      login l, l

      get :edit, :id => teams(:team_ossa).id
      assert_response :success
    end
  end

  def a_test_should_update_team
    %w(admin manager).each do |l|
      login l, l

      put :update, :id => teams(:one).id, :team => { }
      assert_redirected_to team_path(assigns(:team))
    end
  end

end
