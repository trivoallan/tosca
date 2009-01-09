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

class ChangelogsControllerTest < ActionController::TestCase
  fixtures :changelogs

  def setup
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template nil #testing that the page is empty
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:changelog)
    assert assigns(:changelog).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:changelog)
  end

  def test_create
    num_changelogs = Changelog.count

    post :create, :changelog => { :modification_date => '2005-10-26 10:20:00',
                                  :modification_text => "long description" }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_changelogs + 1, Changelog.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:changelog)
    assert assigns(:changelog).valid?
  end

  def test_update
    post :update, :id => 1

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Changelog.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Changelog.find(1)
    }
  end
end
