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

class RequestsControllerTest < ActionController::TestCase

  fixtures :all

  def test_pending
    %w(admin manager expert customer).each do |l|
      login l, l
      get :pending
      assert_response :success
      assert_template 'pending'
    end
  end

  def test_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'

      check_ajax_filter(:contract_id, Contract.find(:first).id, :requests)
      check_ajax_filter(:ingenieur_id, Ingenieur.find(:first).id, :requests)
      check_ajax_filter(:typerequest_id, Typerequest.find(:first).id, :requests)
      check_ajax_filter(:severite_id, Severite.find(:first).id, :requests)
      check_ajax_filter(:statut_id, Statut.find(:first).id, :requests)
      # The search box cannot be checked with the helper
      xhr :get, :index, :filters => { :text => "openoffice" }
      assert_response :success
    end
  end

  def test_edit
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => Request.find(:first).id
      assert_response :success
      assert_template 'edit'

      _test_ajax_form_methods
      logout
    end
  end

  def test_update
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => Request.find(:first).id
      assert_response :success
      assert_template 'edit'

      new_descr = "edited by #{l}"
      form = select_form 'main_form'
      form.request.description = new_descr
      form.submit

      assert_response :redirect
      # p assigns(:request).errors.full_messages
      assert assigns(:request).errors.empty?
      assert_equal assigns(:request).description, new_descr

      logout
    end
  end

  def test_new
    %w(admin manager expert customer).each do |l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      _test_ajax_form_methods
      logout
    end
  end

  def test_create
    %w(admin manager expert customer).each {|l|
      login l, l
      get :new
      assert_response :success
      assert_template 'new'

      form = select_form 'main_form'
      form.request.resume = "there is a problem with foo"
      form.request.description = "it's a bar"
      form.submit

      # p assigns(:request).errors.full_messages
      assert_response :redirect
      # TODO : I did not manage to test correctly :
      # redirected with an url starting with new_requests_path
      assert assigns(:request).errors.empty?
      # It ensure that contract won't be passed between 2 logins
      # since the controller is the same instance in test environnement
      assigns(:request).contract = nil
    }
  end

  def test_show
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      request_id = session[:user].contracts.first.requests.first.id
      get :show, :id => request_id
      assert_response :success
      assert_template 'show'

      xhr :get, :ajax_description, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_description'

      xhr :get, :ajax_comments, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_comments'

      xhr :get, :ajax_history, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_history'

      xhr :get, :ajax_appels, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_appels'

      xhr :get, :ajax_attachments, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_attachments'

      xhr :get, :ajax_cns, :id => request_id
      assert_response :success
      assert_template 'requests/tabs/_tab_cns'
    }
  end

  def test_link_contribution
    %w(admin manager expert).each { |l|
      login l, l
      request = session[:user].contracts.first.requests.first
      contribution_id = request.software.contributions.first.id

      post :link_contribution, :id => request.id, :contribution_id => contribution_id
      assert_response :redirect
      assert_redirected_to request_path(request.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)

      post :unlink_contribution, :id => request.id
      assert_response :redirect
      assert_redirected_to request_path(request.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)
    }
  end

  def test_print
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      request_id = session[:user].contracts.first.requests.first.id
      get :print, :id => request_id
      assert_response :success
      assert_template 'print'
    }
  end

  private
  def _test_ajax_form_methods
    # test the 3 ajax methods
    xhr :get, :ajax_display_commitment, :request => { :severite_id => '2',
      :typerequest_id => '2' }
    assert_response :success

    xhr :get, :ajax_display_version, :request => { :software_id => "1",
      :socle_id => "1"}
    assert_response :success

    xhr :get, :ajax_display_contract, :contract_id => session[:user].contracts.first.id
    assert_response :success
  end

end
