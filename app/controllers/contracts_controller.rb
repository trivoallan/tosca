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
class ContractsController < ApplicationController
  helper :clients, :commitments, :ingenieurs, :versions, :issues

  auto_complete_for :user, :name, :contract, :engineer_user,
                    :conditions => { :client => false }

  def index
    options = { :per_page => 25, :include => [:client],
                :order => 'contracts.client_id' }

    if params.has_key? :filters
      session[:contracts_filters] = Filters::Contracts.new(params[:filters])
    end

    conditions = nil
    contracts_filters = session[:contracts_filters]
    if contracts_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(contracts_filters, [
        [:text, 'clients.name', 'contracts.name', :dual_like ]
      ])
      @filters = contracts_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @contract_pages, @contracts = paginate :contracts, options

    # panel on the left side.
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_for_summary = 'contracts_info'
    end
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :order =>
      'contracts.end_date', :conditions => 'clients.inactive = 0' }
    @contract_pages, @contracts = paginate :contracts, options
    render :action => 'index'
  end

  def show
    @contract = Contract.find(params[:id])
    @teams = @contract.teams
    @versions = @contract.versions
  end

  def new
    # It is the default contract
    @contract = Contract.new
    @contract.client_id = params[:id]
    @contract.rule_type = 'Rules::Component'
    @contract.opening_time, @contract.closing_time = 9, 18
    _form
  end

  def ajax_choose
    value = params[:value]
    render :nothing => true and return unless request.xhr? && !value.blank?
    @rules = []
    if value.grep(/^Rules::/) # H@k3rz protection
      @rules = value.constantize.find_select
    end
    @type = 'rules' unless @rules.empty?
  end

  def create
    _aggregate_commitments
    # It's needed because manager are scoped, at this point
    Client.send(:with_exclusive_scope) do
      @contract = Contract.new(params[:contract])
      @contract.creator = session[:user]
      # Due to a limitation of Rails <= 2.1, we cannot create a full
      # association in one pass.
      # TODO : review this problem on a > Rails
      engineers =  @contract.engineer_users.dup
      @contract.engineer_users = []
      if @contract.save
        @contract.update_attribute :engineer_users, engineers
        flash[:notice] = _('Contract was successfully created.')
        redirect_to contracts_path
      else
        @contract.engineer_users = engineers
        _form and render :action => 'new'
      end
    end
  end

  def edit
    @contract = Contract.find(params[:id])
    _form
  end

  def update
    @contract = Contract.find(params[:id])
    @contract.creator = session[:user] unless @contract.creator
    _aggregate_commitments
    if @contract.update_attributes(params[:contract])
      flash[:notice] = _('Contract was successfully updated.')
      redirect_to contract_path(@contract)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contract.find(params[:id]).destroy
    redirect_to contracts_path
  end

  def ajax_add_software
    selected = params[:select]
    if selected.blank? || !selected.has_key?(:software)
      return render(:nothing => true)
    end
    @software = Software.find(selected[:software])
    render(:update) { |page|
      page.insert_html(:before, "end", :partial => "software")
      page.visual_effect(:appear, @random_id)
    }
  end

  def supported_software
    @contract = Contract.find(params[:id]) unless @contract
    @versions = @contract.versions
    @softwares = Software.find_select
  end

  def add_software
    @contract = Contract.find(params[:id])
    software = params['software'] || []
    versions = Array.new
    software.each do |s|
      # get rid of the random_field hack
      s = s[1]
      next unless s.is_a? Hash
      # It's 2 lines but fast find_or_create call
      version = Version.find(:first, :conditions => s, :include => :software)
      version = Version.create(s) unless version
      versions << version if version.valid?
    end
    @contract.versions = versions
    if @contract.save
      redirect_to contract_path(@contract)
    else
      supported_software and render :action => supported_software
    end
  end

  def tags
    @contract = Contract.find(params[:id])
    # We get the tags only for this contract
    @tags = Issue.tag_counts(:conditions => { :contract_id => @contract.id })
    if params[:tag] and not params[:tag].empty?
      tags = params[:tag].split(",")
      @issues = Issue.find_tagged_with(tags,
        :conditions => { :contract_id => @contract.id })
      @tag_with = tags
    end
  end

private
  def _form
    # Needed in order to be able to auto-associate with it
    Client.send(:with_exclusive_scope) do
      @clients = Client.find_select
    end
    @commitments = Commitment.find(:all, Commitment::OPTIONS)
    @ingenieurs = User.find_select(User::EXPERT_OPTIONS)
    @teams = Team.find_select
    @contract_team = @contract.teams
    @rules = []
    begin
      @rules = @contract.rule_type.constantize.find_select
    rescue Exception => e
      flash[:warn] = _('Unknown rules for contract "%s"') % e.message
    end
  end

  # Since Html lack of aggregation between multiple select, we have to do it
  # manually. It's a shame, and it's quite slow.
  # TODO : find a better way
  def _aggregate_commitments
    contract, ids = params[:contract], []
    return unless contract
    contract.keys.grep(/^commitment_ids/).each{|k|
      value = contract.delete(k)
      ids << value unless value == '0'
    }
    contract[:commitment_ids] = ids
  end

  def _panel
  end

end
