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

class ReleasesControllerTest < ActionController::TestCase
  fixtures :versions, :softwares, :releases, :contracts, :clients,
    :credits, :components

  def test_should_get_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      assert_not_nil assigns(:releases)
    end
  end

  def test_should_create_release
    %w(admin manager).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      assert_difference('Release.count') do
        form = select_form 'main_form'
        form.release.name = "rc 1"
        form.submit
      end
      assert_redirected_to version_path(assigns(:release).version)
    end
  end

  def test_should_show_release
    %w(admin manager expert).each do |l|
      login l, l
      get :show, :id => Release.first(:order => :id).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager).each do |l|
      login l, l

      get :edit, :id => Release.first(:order => :id).id
      assert_response :success
    end
  end

  def a_test_should_update_release
    %w(admin manager).each do |l|
      login l, l

      put :update, :id => releases(:one).id, :release => { }
      assert_redirected_to release_path(assigns(:release))
    end
  end

end
