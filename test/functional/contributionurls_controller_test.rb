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
require 'contributionurls_controller'

# Re-raise errors caught by the controller.
class ContributionurlsController; def rescue_action(e) raise e end; end

class ContributionurlsControllerTest < Test::Unit::TestCase
  fixtures :contributionurls

  def setup
    @controller = ContributionurlsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contributionurls)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contributionurl)
    assert assigns(:contributionurl).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contributionurl)
  end

  def test_create
    num_contributionurls = Contributionurl.count

    post :create, :contributionurl => {
      :valeur => 'une valeur',
      :contribution_id => 1
    }

    assert_response :redirect
    assert_redirected_to contribution_path(1)

    assert_equal num_contributionurls + 1, Contributionurl.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contributionurl)
    assert assigns(:contributionurl).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to contribution_path(1)
  end

  def test_destroy
    assert_not_nil Contributionurl.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contributionurl.find(1)
    }
  end
end
