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

class IssuesControllerTest < ActionController::TestCase

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

      check_ajax_filter(:contract_id, Contract.find(:first).id, :issues)
      check_ajax_filter(:ingenieur_id, Ingenieur.find(:first).id, :issues)
      check_ajax_filter(:typeissue_id, Typeissue.find(:first).id, :issues)
      check_ajax_filter(:severity_id, Severity.find(:first).id, :issues)
      check_ajax_filter(:statut_id, Statut.find(:first).id, :issues)
      # The search box cannot be checked with the helper
      xhr :get, :index, :filters => { :text => "openoffice" }
      assert_response :success
    end
  end

  def test_edit
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => Issue.find(:first).id
      assert_response :success
      assert_template 'edit'

      _test_ajax_form_methods
      logout
    end
  end

  def test_update
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => Issue.find(:first).id
      assert_response :success
      assert_template 'edit'

      new_descr = "edited by #{l}"
      form = select_form 'main_form'
      form.issue.description = new_descr
      form.submit

      assert_response :redirect
      # p assigns(:issue).errors.full_messages
      assert assigns(:issue).errors.empty?
      assert_equal assigns(:issue).description, new_descr

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
      form.issue.resume = "there is a problem with foo"
      form.issue.description = "it's a bar"
      form.submit

      # p assigns(:issue).errors.full_messages
      assert_response :redirect
      # TODO : I did not manage to test correctly :
      # redirected with an url starting with new_issues_path
      assert assigns(:issue).errors.empty?
      # It ensure that contract won't be passed between 2 logins
      # since the controller is the same instance in test environnement
      assigns(:issue).contract = nil
    }
  end

  def test_show
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      issue_id = session[:user].contracts.first.issues.first.id
      get :show, :id => issue_id
      assert_response :success
      assert_template 'show'

      xhr :get, :ajax_comments, :id => issue_id
      assert_response :success
      assert_template 'issues/tabs/_tab_comments'

      xhr :get, :ajax_history, :id => issue_id
      assert_response :success
      assert_template 'issues/tabs/_tab_history'

      xhr :get, :ajax_phonecalls, :id => issue_id
      assert_response :success
      assert_template 'issues/tabs/_tab_phonecalls'

      xhr :get, :ajax_attachments, :id => issue_id
      assert_response :success
      assert_template 'issues/tabs/_tab_attachments'

      xhr :get, :ajax_cns, :id => issue_id
      assert_response :success
      assert_template 'issues/tabs/_tab_cns'
    }
  end

  def test_link_contribution
    %w(admin manager expert).each { |l|
      login l, l
      issue = session[:user].contracts.first.issues.first
      contribution_id = issue.software.contributions.first.id

      post :link_contribution, :id => issue.id, :contribution_id => contribution_id
      assert_response :redirect
      assert_redirected_to issue_path(issue.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)

      post :unlink_contribution, :id => issue.id
      assert_response :redirect
      assert_redirected_to issue_path(issue.id)
      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)
    }
  end

  def test_print
    %w(admin manager expert customer viewer).each {|l|
      login l, l
      issue_id = session[:user].contracts.first.issues.first.id
      get :print, :id => issue_id
      assert_response :success
      assert_template 'print'
    }
  end

  private
  def _test_ajax_form_methods
    # test the 3 ajax methods
    xhr :get, :ajax_display_commitment, :issue => { :severity_id => '2',
      :typeissue_id => '2' }
    assert_response :success

    xhr :get, :ajax_display_version, :issue => { :software_id => "1",
      :socle_id => "1"}
    assert_response :success

    xhr :get, :ajax_display_contract, :contract_id => session[:user].contracts.first.id
    assert_response :success
  end

end
