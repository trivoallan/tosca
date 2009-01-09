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

class CommentsControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_new
    get :new
    assert_response :success
    assert_template nil
  end

  def test_create
    get :create
    assert_response :success
    assert_template nil
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:comments)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:comment)
    assert assigns(:comment)
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:comment)
    assert assigns(:comment)
  end

  def test_update
    post :update, {
      :id => 1,
      :comment => {
        :issue_id => 1,
        :user_id => 2,
        :attachment_id => 1,
        :text => 'Voici un autre comment',
        :private => 0,
        :created_on => '2006-09-21 08:19:30',
        :updated_on => '2007-07-12 14:21:17',
        :severity_id => 1,
        :statut_id => 7,
        :engineer_id => 1
      }
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end


  # This test is one of the severe issue encountered in production
  # It was when a comment posted for cancellation of a issue,
  # put back issue in "saved" status.
  def test_comment
    old_statut_id = Issue.find(1).statut_id

    post(:comment, { :id => "2-une-autre-issues",
      :comment => {
        "text" => "promenons nous dans les bois",
        "private" => "0",
        "engineer_id" => "",
        "severity_id" => "",
        "statut_id" => "3"
      },
      :mce_editor_0_formatSelect => "",
      :attachment => { "file_temp" => "", "file" => "" }
         })

    # TODO : why it's not a success ????
    assert_response :redirect
    assert_redirected_to(:controller => "issues", :action => "show",
                         :id => "2-Copy-something-in-a-software")

    assert(Issue.find(1).statut_id == old_statut_id)
  end

end
