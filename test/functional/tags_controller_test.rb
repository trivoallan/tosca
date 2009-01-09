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

class TagsControllerTest < ActionController::TestCase
  fixtures :tags, :users, :contracts, :contracts_users

  def test_should_get_index
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :index
      assert_response :success
      assert_not_nil assigns(:tags)
    end
  end

  def test_should_get_new
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :new
      assert_template 'new'
      assert_response :success
    end
  end

  def test_should_create_tag
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :new
      assert_difference('Tag.count') do
        form = select_form "main_form"
        form["tag[name]"] = "Facile #{l}"
        form.submit
      end

      assert_redirected_to tags_path
    end
  end

  def test_should_show_tag
    %w(admin manager expert customer viewer).each do |l|
      login l, l
      get :show, :id => tags(:tag_00001).id
      assert_response :success
    end
  end

  def test_should_get_edit
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => tags(:tag_00001).id
      assert_response :success
    end
  end

  def test_should_update_tag
    %w(admin manager).each do |l|
      login l, l
      get :edit, :id => tags(:tag_00001).id
      form = select_form "main_form"
      form["tag[name]"] = "Facile #{l}"
      form.submit
      assert_redirected_to tag_path(assigns(:tag))
    end
  end

  def test_should_destroy_tag
    %w(admin).each do |l|
      login l, l
      assert_difference('Tag.count', -1) do
        delete :destroy, :id => tags(:tag_00001).id
      end

      assert_redirected_to tags_path
    end
  end
end
