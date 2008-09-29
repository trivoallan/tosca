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
  helper :filters, :issues, :versions, :export, :urlreversements, :softwares

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
      @software = Software.find(params[:id])
      options[:conditions] = { :software_id => @software.id }
    end
    client_id = params[:client_id].to_s
    unless client_id.blank? || client_id == '1' # Main client
      options[:conditions].merge!({'contracts.client_id' => params[:client_id]})
      options[:include] = {:issue => :contract}
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
      options = { :order => 'softwares.name ASC' }
      options[:joins] = :contributions
      options[:select] = 'DISTINCT softwares.*'
      unless client_id.blank? || client_id == '1'
        options[:conditions] = { 'contracts.client_id' => params[:client_id] }
        options[:joins] = { :contributions => { :issue => :contract } }
      end
      # Dirty hack in order to show main client' contributions
      # TODO : remove it in september.
      condition = (client_id == '1' ? "contributions.id_mantis IS NOT NULL" : '')
      scope = { :find => { :conditions => condition } }
      Software.send(:with_scope, scope) do
        @softwares = Software.find(:all, options)
      end
    end
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC',
      :include => [:software,:etatreversement,:issue] }

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
        [:software, 'softwares.name', :like ],
        [:contribution, 'contributions.name', :like ],
        [:etatreversement_id, 'contributions.etatreversement_id', :equal ],
        [:ingenieur_id, 'contributions.ingenieur_id', :equal ],
        [:contract_id, 'issues.contract_id', :equal ]
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
    @contribution.software_id = params[:software_id]
    # submitted state, by default
    @contribution.etatreversement_id = 4
    @contribution.contributed_on = Date.today
    @issue = Issue.new(); @issue.id = params[:issue_id]
    @contribution.ingenieur = @ingenieur
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if _link2issue && @contribution.save
      flash[:notice] = _('The contribution has been created successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contribution = Contribution.find(params[:id])
    @issue = @contribution.issue
    _form
  end

  def show
    @contribution = Contribution.find(params[:id])
  end

  def update
    @contribution = Contribution.find(params[:id])
    if _link2issue && @contribution.update_attributes(params[:contribution])
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
    return render(:nothing => true) unless issue.xml_http_issue? and params[:software_id]
    @versions = Software.find(params[:software_id]).versions.find_select # collect { |v| [v.full_software_name, v.id] }
  end

private
  def _form
    @softwares = Software.find_select
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @typecontributions = Typecontribution.find_select
    if @contribution.software_id
      @versions = @contribution.software.versions.find_select
    else
      @versions = Version.all.find_select # collect { |v| [v.full_software_name, v.id] }
    end
  end

  def _panel
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @softwares = Software.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
    # count
    csoftwares = { :select => 'contributions.software_id', :distinct => true }
    @count = {:contributions => Contribution.count,
      :softwares => Contribution.count(csoftwares) }
  end

  def _update(contribution)
    url = params[:urlreversement]
    contribution.urlreversements.create(url) unless url.blank?
    contribution.contributed_on = nil if params[:contribution][:reverse] == '0'
    contribution.closed_on = nil if params[:contribution][:clos] == '0'
    contribution.save
  end

  def _link2issue()
    begin
      issue = Issue.find(params[:issue][:id].to_i) unless params[:issue][:id].blank?
      @contribution.issue = issue
      true
    rescue
      flash[:warn] = _('The associated issue does not exist')
      false
    end
  end
end
