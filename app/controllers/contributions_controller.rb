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
class ContributionsController < ApplicationController
  helper :filters, :requests, :versions, :export, :urlreversements, :logiciels

  cache_sweeper :contribution_sweeper, :only => [ :create, :update ]

  # Show all contribs and who's done 'em
  def experts
    options = { :order => 'contributions.ingenieur_id, contributions.etatreversement_id' }
    @contributions = Contribution.find(:all, options)
  end

  def index
    select
    render :action => "select"
  end

  def list
    options = { :order => "contributions.created_on DESC" }
    options[:conditions] = { }
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      options[:conditions] = { :logiciel_id => @logiciel.id }
    end
    client_id = params[:client_id].to_s
    unless client_id.blank? || client_id == '1' # Main client
      options[:conditions].merge!({'contracts.client_id' => params[:client_id]})
      options[:include] = {:request => :contract}
    end
    # Dirty hack in order to show main client' contributions
    # TODO : remove it in september.
    condition = (client_id == '1' ? "contributions.id_mantis IS NOT NULL" : '')
    scope = { :find => { :conditions => condition } }
    Contribution.send(:with_scope, scope) do
      @contribution_pages, @contributions = paginate :contributions, options
    end
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def select
    client_id = params[:client_id].to_s
    unless read_fragment "contributions/select_#{client_id || 'all'}"
      options = { :order => 'logiciels.name ASC' }
      options[:joins] = :contributions
      options[:select] = 'DISTINCT logiciels.*'
      unless client_id.blank? || client_id == '1'
        options[:conditions] = { 'contracts.client_id' => params[:client_id] }
        options[:joins] = { :contributions => { :request => :contract } }
      end
      # Dirty hack in order to show main client' contributions
      # TODO : remove it in september.
      condition = (client_id == '1' ? "contributions.id_mantis IS NOT NULL" : '')
      scope = { :find => { :conditions => condition } }
      Logiciel.send(:with_scope, scope) do
        @logiciels = Logiciel.find(:all, options)
      end
    end
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC',
      :include => [:logiciel,:etatreversement,:request] }

    if params.has_key? :filters
      session[:contributions_filters] =
        Filters::Contributions.new(params[:filters])
    end
    conditions = nil
    contributions_filters = session[:contributions_filters]
    if contributions_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(contributions_filters, [
        [:software, 'logiciels.name', :like ],
        [:contribution, 'contributions.name', :like ],
        [:etatreversement_id, 'contributions.etatreversement_id', :equal ],
        [:ingenieur_id, 'contributions.ingenieur_id', :equal ],
        [:contract_id, 'requests.contract_id', :equal ]
      ])
      @filters = contributions_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @contribution_pages, @contributions = paginate :contributions, options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'contributions_admin', :layout => false
    else
      _panel
      @partial_for_summary = 'contributions_info'
    end
  end

  def new
    @contribution = Contribution.new
    @urlreversement = Urlreversement.new
    # we can precise the software with this, see software/show for more info
    @contribution.logiciel_id = params[:logiciel_id]
    # submitted state, by default
    @contribution.etatreversement_id = 4
    @contribution.contributed_on = Date.today
    @request_tosca = Request.new(); @request_tosca.id = params[:request_id]
    @contribution.ingenieur = @ingenieur
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if _link2request && @contribution.save
      flash[:notice] = _('The contribution has been created successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contribution = Contribution.find(params[:id])
    @request_tosca = @contribution.request
    _form
  end

  def show
    @contribution = Contribution.find(params[:id])
  end

  def update
    @contribution = Contribution.find(params[:id])
    if _link2request && @contribution.update_attributes(params[:contribution])
      flash[:notice] = _('The contribution has been updated successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contribution.find(params[:id]).destroy
    redirect_to contributions_path
  end

  def ajax_list_versions
    return render(:nothing => true) unless request.xml_http_request? and params[:logiciel_id]
    @versions = Logiciel.find(params[:logiciel_id]).versions.find_select # collect { |v| [v.full_software_name, v.id] }
  end

private
  def _form
    @logiciels = Logiciel.find_select
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @typecontributions = Typecontribution.find_select
    if @contribution.logiciel_id
      @versions = @contribution.logiciel.versions.find_select
    else
      @versions = Version.all.find_select # collect { |v| [v.full_software_name, v.id] }
    end
  end

  def _panel
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @logiciels = Logiciel.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
    # count
    clogiciels = { :select => 'contributions.logiciel_id', :distinct => true }
    @count = {:contributions => Contribution.count,
      :logiciels => Contribution.count(clogiciels) }
  end

  def _update(contribution)
    url = params[:urlreversement]
    contribution.urlreversements.create(url) unless url.blank?
    contribution.contributed_on = nil if params[:contribution][:reverse] == '0'
    contribution.closed_on = nil if params[:contribution][:clos] == '0'
    contribution.save
  end

  def _link2request()
    begin
      request = Request.find(params[:request][:id].to_i) unless params[:request][:id].blank?
      @contribution.request = request
      true
    rescue
      flash[:warn] = _('The associated request does not exist')
      false
    end
  end
end
