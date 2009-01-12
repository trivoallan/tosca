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
class SubscriptionsController < ApplicationController
  # GET /subscriptions
  def index
    @subscriptions = Subscription.all
  end

  # GET /subscriptions/1
  def show
    @subscription = Subscription.find(params[:id])
  end

  # GET /subscriptions/new
  def new
    render(:nothing => true)
  end

  # GET /subscriptions/1/edit
  def edit
    render(:nothing => true)
  end

  # POST /subscriptions
  def create
    render(:nothing => true)
  end

  # PUT /subscriptions/1
  def update
    render(:nothing => true)
  end

  # DELETE /subscriptions/1
  def destroy
    render(:nothing => true)
  end

end
