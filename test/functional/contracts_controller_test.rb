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

class ContractsControllerTest < ActionController::TestCase

  fixtures :contracts, :commitments, :clients, :severites, :typeissues,
    :credits, :components, :softwares

  def setup
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contracts)
  end

  def test_actives
    get :actives
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contracts)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contract)
    assert assigns(:contract).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contract)
  end

  def test_create
    get :new
    assert_difference('Contract.count') do
      form = select_form "main_form"
      form.contract.opening_time = 9
      form.contract.closing_time = 18
      form.submit
      assert flash.has_key?(:notice)
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contract)
    assert assigns(:contract).valid?
  end

  def test_update
    get :edit, :id => 1
    form = select_form "main_form"
    form.submit

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Contract.find(1)

    post :destroy, :id => 1

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contract.find(1)
    }
  end

  def test_supported_software
    get :supported_software, :id => 1
    assert_response :success
    assert_template 'supported_software'
    versions = Contract.find(1).versions
    assert_no_difference('Version.count') do
      form = select_form "main_form"
      form.submit
      assert_response :redirect
      assert_redirected_to contract_path(:id => 1)
    end
  end

  def test_add_software
    get :supported_software, :id => 1
    assert_response :success
    assert_template 'supported_software'
    versions = Contract.find(1).versions
    assert_no_difference('Version.count') do
      form = select_form "main_form"
      form.submit
    end
    xhr :post, :ajax_add_software, :select => {
      :software => Software.find(:first).id }
    assert_response :success
    assert_template 'contracts/_software'
  end

end
