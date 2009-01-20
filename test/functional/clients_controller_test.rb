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

class ClientsControllerTest < ActionController::TestCase
 fixtures :clients, :contracts, :credits, :components

  def setup
    login 'admin', 'admin'
  end

  def test_index
    %w(admin manager expert).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:clients)

      # The search box cannot be checked with the helper
      xhr :get, :index, :filters => { :text => "linagora" }
      assert_response :success
    end
  end

  def test_show
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      get :show, :id => session[:user].client_ids.first
      assert_response :success
      assert_template 'show'
      assert_not_nil assigns(:client)
      assert assigns(:client).valid?
    }
  end

  def test_new
    # done in test_create
  end

  def test_create
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:client)

    assert_difference('Client.count') do
      submit_with_name :client, "this is an automatic test client"
    end

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to new_contract_path(:id => assigns(:client).id)
  end

  def test_edit
    # done in test_update
  end

  def test_update
    get :edit, :id => Client.first(:order => :id).id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:client)
    assert assigns(:client).valid?

    submit_with_name :client, "this is an automatic test client"

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => '1-this-is-an-automatic-test-client'
    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end

  def test_update_logo
    get :edit, :id => Client.first(:order => :id).id
    form = select_form 'main_form'
    form.picture.image = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    form.submit
    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => '1-Linagora'
    assert_not_nil assigns(:client)
    assert assigns(:client).valid?
  end

  def test_destroy
    client = Client.first(:order => :id).clone
    client.save!

    assert_difference('Client.count', -1) do
      post :destroy, :id => client.id
    end
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Client.find(client.id)
    }
    # restore client
    client.save!
  end
end
