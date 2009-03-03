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
class ClientsController < ApplicationController
  helper :issues, :commitments, :contracts

  def index
    options = { :per_page => 15, :order => 'clients.name',
      :include => [:picture], :page => params[:page] }

    options[:conditions] = _clients_filters
    @clients = Client.paginate options

    # panel on the left side.
    if request.xhr?
      render :layout => false
    else
      @partial_panel = 'index_panel'
    end
  end

  def show
    @client = Client.find(params[:id])
    # allows to see only binaries of this client for all without scope
    begin
      Version.set_scope(@client.contract_ids)
      render
    ensure
      Version.remove_scope
    end
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    @client.creator = @session_user
    if add_logo && @client.save
      flash[:notice] = _('Client created successfully.') + '<br />' +
        _('You have now to create the associated contract.')
      redirect_to new_contract_path(:id => @client.id)
    else
      render :action => 'new'
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if add_logo && @client.update_attributes(params[:client])
      flash[:notice] = _('Client updated successfully.')
      redirect_to client_path(@client)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to clients_path
  end

  private

  def _clients_filters
    if params.has_key? :filters
      session[:clients_filters] = Filters::Clients.new(params[:filters])
    end

    conditions = nil
    clients_filters = session[:clients_filters]
    if clients_filters
      # Here is the trick for the "active" part of the view
      special_cond = _active_filters(clients_filters[:active])

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(clients_filters, [
        [:text, 'clients.name',
                'clients.context',
                'clients.address', :multiple_like ]
      ], special_cond)
      @filters = clients_filters
    end
    conditions
  end

  def add_logo
    image = params[:picture]
    unless image.nil? || image[:image].blank?
      image[:description] = @client.name
      @client.picture = Picture.new(image)
      @client.picture.save
    else
      true
    end
  end

  # A small helper which set current flow filters
  # for index view
  def _active_filters(value)
    case value.to_i
    when -1
      @title = _('Inactive clients')
      [ 'clients.inactive = ?', true ]
    else # '1' & default are the same.
      @title = _('Active clients')
      [ 'clients.inactive = ?', false ]
    end
  end

end
