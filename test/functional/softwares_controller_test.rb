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

class SoftwaresControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_index
    browse_index
    # test public access
    logout
    browse_index
  end

  def browse_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:softwares)

    # tests the ajax filters
    xhr :get, :index, :filters => { :contract_id => 3}
    assert_response :success
    assigns(:softwares).each do |l|
      software = Software.find l.id
      assert_equal software.versions.first.contract.id, 3
    end

    xhr :get, :index, :filters => { :group_id => 2 }
    assert_response :success
    assigns(:softwares).each { |l| assert_equal l.group_id, 2 }
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:software)
    assert assigns(:software)
  end

  # Some software should not be publicly visible.
  def test_public_access
    get :show, :id => 4
    assert_response :success
    assert_template 'show'

    logout
    assert_raise(ActiveRecord::RecordNotFound) {
      get :show, :id => 4
    }
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:software)
  end

  def test_create
    get :new
    assert_difference('Software.count') do
      form = select_form 'form_software'
      form.software.name = 'Ant'
      form.software.group_id = 4
      form.software.summary = 'compilation java tool'
      form.software.skill_ids = '1'
      form.submit
    end

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to(:action => 'show',
        :id => "5-Ant", :controller => "softwares")
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:software)
    assert assigns(:software)
  end

  def test_update
    get :edit, :id => 1
    p assigns(:software)
    p assigns(:software).skills

    form = select_form 'form_software'
    form.software.name = 'OOo'
    form.submit

    assert_response :success
    p assigns(:software)
    p assigns(:software).skills
    p assigns(:software).errors
    assert flash.has_key?(:notice)
    assert_redirected_to({:action =>"show", :id => "1-OOo",
                           :controller => "softwares"})
  end

  def test_destroy
    assert_not_nil Software.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Software.find(1)
    }
  end
end
