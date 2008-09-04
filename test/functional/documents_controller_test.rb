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

class DocumentsControllerTest < ActionController::TestCase
  fixtures :documents, :typedocuments, :clients, :roles, :permissions,
    :permissions_roles, :users, :contracts, :contracts_users

  def test_index
    %w(admin manager expert customer viewer).each { |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'select'
      assert_not_nil assigns(:typedocuments)
    }
  end

  def test_list
    %w(admin manager expert customer viewer).each { |l|
      login l, l
      get :list, :id => 1

      assert_response :success
      assert_template 'list'
      assert_not_nil assigns(:documents)
    }
  end

  def test_show
    %w(admin manager expert).each { |l|
      login l, l
      get :show, :id => Document.find(:first).id

      assert_response :success
      assert_template 'show'

      assert_not_nil assigns(:document)
      assert assigns(:document).valid?
    }
  end

  def test_create
    %w(admin manager expert).each { |l|
      login l, l
      num_documents = Document.count
      get :new

      assert_response :success
      assert_template 'new'
      assert_not_nil assigns(:document)

      form = select_form 'main_form'
      form.document.title = "this is a legal picture"
      form.document.file = uploaded_png("#{File.expand_path(RAILS_ROOT)}/test/fixtures/upload_document.png")
      form.submit

      assert flash.has_key?(:notice)
      assert !flash.has_key?(:warning)
      assert_response :redirect
      assert_redirected_to :action => 'select'

      assert_equal num_documents + 1, Document.count
    }
  end

  def test_update
    %w(admin manager expert).each { |l|
      login l, l
      get :edit, :id =>  Document.find(:first).id
      assert_response :success
      assert_template 'edit'
      assert_not_nil assigns(:document)

      form = select_form 'main_form'
      form.document.title = "this is a new title"
      form.submit

      assert_response :redirect
      assert_redirected_to :action => 'show'
    }
  end

  def test_destroy
    login 'admin', 'admin'
    document = Document.find(:first)
    assert_not_nil document

    post :destroy, :id => document.id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Document.find(document.id)
    }
    document.save
  end
end
