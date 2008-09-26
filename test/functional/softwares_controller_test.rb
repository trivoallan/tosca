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
require 'logiciels_controller'

# Re-raise errors caught by the controller.
class LogicielsController; def rescue_action(e) raise e end; end

class LogicielsControllerTest < Test::Unit::TestCase
  fixtures :logiciels, :competences, :requests, :comments, :contracts,
    :recipients, :contributions, :users, :clients, :credits, :components

  def setup
    @controller = LogicielsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:logiciels)

    # tests the ajax filters
    xhr :get, :index, :filters => { :contract_id => 3}
    assert_response :success
    assigns(:logiciels).each do |l|
      software = Logiciel.find l.id
      assert_equal software.versions.first.contract.id, 3
    end

    xhr :get, :index, :filters => { :groupe_id => 2 }
    assert_response :success
    assigns(:logiciels).each { |l| assert_equal l.groupe_id, 2 }

  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:logiciel)
    assert assigns(:logiciel)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:logiciel)
  end

  def test_create
    num_logiciels = Logiciel.count

    post :create, :logiciel => {
      :name=> 'ANT',
      :groupe_id=> 4,
      :referent=> 'ant',
      :description=> 'un bon logiciel.',
      :resume=> 'Outil de compilation pour java',
      :license_id=> 2,
      :competence_ids => [1]
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_logiciels + 1, Logiciel.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:logiciel)
    assert assigns(:logiciel)
  end

  def test_update
    options = {
        :name => 'ANT',
        :groupe_id=> 4,
        :referent=> 'ant',
        :description=> 'un bon logiciel.',
        :resume=> 'Outil de compilation pour java',
        :license_id=> 2,
        :competence_ids => [1]
    }
    post :update, { :id => 1, :logiciel => options }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to({:action =>"show", :id => "1-ANT",
                           :controller => "logiciels"})
  end

  def test_destroy
    assert_not_nil Logiciel.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Logiciel.find(1)
    }
  end
end
