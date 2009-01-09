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
require 'test_helper'

class HyperlinksControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hyperlinks)
  end

  def test_should_create_hyperlink
    get :new, :model_type => 'contribution', :model_id => 1
    assert_response :success
    form = select_form 'new_hyperlink'
    form.hyperlink.name = 'http://www.tosca-project.net'
    assert_difference('Hyperlink.count') { form.submit }

    assert_response :redirect
    assert_redirected_to(:controller => 'contributions',
                         :action => :show, :id => 1)
  end

  def test_should_show_hyperlink
    get :show, :id => hyperlinks(:hyperlink_00001).id
    assert_response :success
  end

  def test_should_update_hyperlink
    hyperlink = hyperlinks(:hyperlink_00001)
    get :edit, :id => hyperlink.id
    assert_response :success

    form = select_form "edit_hyperlink_#{hyperlink.id}"
    form.hyperlink.name = 'http://redmine.tosca-project.net'
    form.submit
    assert_response :redirect
    assert_redirected_to(:controller => hyperlink.model_type.pluralize,
                         :action => :show, :id => hyperlink.model_id)
  end

  def test_should_destroy_hyperlink
    hyperlink = hyperlinks(:hyperlink_00001)
    assert_difference('Hyperlink.count', -1) do
      delete :destroy, :id => hyperlink.id
    end

    assert_response :redirect
    assert_redirected_to(:controller => hyperlink.model_type.pluralize,
                         :action => :show, :id => hyperlink.model_id)
    hyperlink.save
  end

end
