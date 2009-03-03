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
class IssuesController < ApplicationController
  helper :contributions, :softwares, :comments,
    :account, :reporting, :links, :subscriptions

  cache_sweeper :issue_sweeper, :only =>
    [:create, :update, :destroy, :link_contribution, :unlink_contribution, :ajax_add_tag]

  def pending
    user = @session_user
    @own_issues = Issue.find_pending_user(user)

    @tam_issues = []
    unless user.recipient?
      @tam_issues = Issue.find_pending_contracts(user.managed_contract_ids)
      @tam_issues = @tam_issues - @own_issues
    end

    @team_issues = Issue.find_pending_contracts(user.contracts)
    @team_issues = @team_issues - @tam_issues - @own_issues

    render :template => 'issues/lists/pending'
  end

  # Track of renewed issue is done with expected_on
  # visual effects are in js.erb view
  def ajax_renew
    expected_on = params[:expected_on].to_i
    @issue_ids = params[:issue_ids] || []
    return if expected_on <= 0 or @issue_ids.empty?
    expected = Time.now + expected_on.days
    Issue.find(@issue_ids).each {|r|
      r.update_attribute(:expected_on, expected)
    }
  end

  def index
    #special case : direct show
    if params.has_key? 'numero'
      redirect_to issue_path(params['numero'].first.to_i) and return
    end

    order = params[:sort] || 'updated_on DESC'

    # Specification of a filter f :
    if params.has_key? :filters
      session[:issues_filters] = Filters::Issues.new(params[:filters])
    end

    conditions = nil
    @title = _('All issues')

    issues_filters = session[:issues_filters]

    # TODO : See if, with cache, no include is faster or not.
    # It has to be changed in the export controller too, for the issue part
    per_page, conditions = 10, []
    if issues_filters
      # Here is the trick for the "flow" part of the view
      special_cond = active_filters(issues_filters[:active])

      # Asked by popular issue
      limit = issues_filters[:limit].to_i
      per_page = limit if limit > 0

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(issues_filters, [
          [:text, 'softwares.name', 'issues.resume', :multiple_like ],
          [:contract_id, 'issues.contract_id', :in ],
          [:engineer_id, 'issues.engineer_id', :equal ],
          [:issuetype_id, 'issues.issuetype_id', :equal ],
          [:severity_id, 'issues.severity_id', :equal ],
          [:statut_id, 'issues.statut_id', :equal ]
        ], special_cond)
      @filters = issues_filters
    end
    options = { :per_page => per_page, :order => order, :page => params[:page],
      :select => Issue::SELECT_LIST, :joins => Issue::JOINS_LIST }

    # Flash is used for export. TODO : should be in the extension.
    flash[:conditions] = options[:conditions] = conditions if conditions

    @issues = Issue.paginate options

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'issues/lists/issues_list', :layout => false
    else
      _panel
      @partial_panel = 'index_panel'
      render :template => 'issues/lists/_issues_list'
    end
  end

  def new
    unless @issue
      @issue = Issue.new(params.has_key?(:issue) ? params[:issue] : nil)
    end
    _form @recipient

    @issue.statut_id = (@session_user.engineer? ? 2 : 1)
    unless params.has_key? :issue
      @issue.set_defaults(@session_user, params)
    end
  end

  def create
    @issue = Issue.new(params[:issue])
    user = @session_user
    @issue.submitter = user # it's the current user
    @issue.statut_id = (user.engineer? ? 2 : 1)

    #If we have only one contract possible we auto asign it to the request
    if @issue.contract.nil?
      contracts = @issue.recipient.contracts
      @issue.contract = contracts.first if contracts.size == 1
    end

    revisions = params[:software][:revision_id] if params[:software]
    @issue.associate_software(revisions)

    if @issue.save
      options = { :conditions => [ 'issues.submitter_id = ?', user.id ]}
      flash[:notice] = _("You have successfully submitted your %s issue.") %
        _ordinalize(Issue.count(options))
      @issue.first_comment.add_attachment(params)
      @comment = @issue.first_comment
      # needed in order to send properly the email
      @issue.first_comment.issue.reload
      flash[:notice] += message_notice(@issue.compute_recipients, @issue.compute_copy)
      redirect_to _similar_issue
    else
      _form @recipient
      render :action => 'new'
    end
  end

  # Used when submitting new issue, in order to select
  # packages which are subjects to SLA.
  def ajax_display_commitment
    return render(:nothing => true) unless params.has_key? :issue
    @issue = Issue.new(params[:issue])
  end

  # Used when submitting new issue, in order to select
  # correct contracts
  def ajax_display_contract
    return render(:nothing => true) unless params.has_key? :contract_id
    contract = Contract.find(params[:contract_id].to_i)
    _form4contract(contract)
  end

  # Used when submitting new issue, in order to select
  # correct version of a software
  def ajax_display_version
    return render(:nothing => true) unless params.has_key? :issue
    @issue = Issue.new(params[:issue])
    _form4versions
  end

  def edit
    @issue = Issue.find(params[:id])
    _form @recipient
  end

  def show
    @issue = Issue.find(params[:id], :include => [:first_comment]) unless @issue
    @page_title = @issue.resume
    @partial_panel = 'show_panel'
    user = @session_user
    unless read_fragment "issues/#{@issue.id}/front-#{user.role_id}"
      @comment = Comment.new(:elapsed => 1, :issue => @issue)
      @comment.text = flash[:old_body] if flash.has_key? :old_body

      # TODO not dry, cf ajax_comments
      options = { :order => 'created_on DESC', :include => [:user],
        :limit => 1, :conditions => { :issue_id => @issue.id } }
      options[:conditions][:private] = false if @recipient
      @last_comment = Comment.first(options)


      @comments = Comment.all(:order => "created_on ASC",
        :conditions => filter_comments(@issue.id), :include => [:user])

      @statuts = @issue.issuetype.allowed_statuses(@issue.statut_id, @session_user)
      if user.engineer?
        @severities = Severity.find_select
        @engineers = User.find_select_by_contract_id(@issue.contract_id)
        @teams = Team.on_contract_id(@issue.contract_id)
      end
    end
    _panel_subscribers
  end

  def ajax_history
    return render(:nothing => true) unless request.xhr?
    @issue_id = params[:id]
    unless read_fragment "issues/#{@issue_id}/history"
      @last_comment = nil # Prevents some insidious call with functionnal tests
      conditions = filter_comments(@issue_id)
      conditions[0] << " AND statut_id IS NOT NULL"
      @comments = Comment.all(:conditions => conditions,
        :order => "created_on ASC", :include => [:user,:statut,:severity])
    end
    render :partial => 'issues/tabs/tab_history', :layout => false
  end

  def ajax_attachments
    return render(:nothing => true) unless request.xhr?
    @issue_id = params[:id]
    set_attachments(@issue_id)
    render :partial => 'issues/tabs/tab_attachments', :layout => false
  end

  def ajax_actions
    return render(:nothing => true) unless request.xhr? and params.has_key? :id
    @issue = Issue.find(params[:id])
    software_id = @issue.software_id
    options =  { :order => 'updated_on DESC', :limit => 10, :conditions =>
        [ 'contributions.software_id = ?', software_id ] }
    @contributions = (software_id ?
        Contribution.all(options).collect{|c| [c.name, c.id]} : [])
    render :partial => 'issues/tabs/tab_actions', :layout => false
  end

  def ajax_cns
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue = Issue.find(params[:id]) unless @issue
    render :partial => 'issues/tabs/tab_cns', :layout => false
  end

  def update
    @issue = Issue.find(params[:id])
    @issue.versions = Paquet.find(params[:version_ids]) if params[:version_ids]
    issue = params[:issue]
    # description is delocalized into the first comment, mainly for db perf.
    description = issue[:description]
    if @issue.update_attributes(issue) &&
        @issue.first_comment.update_attribute(:text, description)
      flash[:notice] = _("The issue has been updated successfully.")
      redirect_to issue_path(@issue)
    else
      _form @session_user
      render :action => 'edit'
    end
  end

  def destroy
    Issue.find(params[:id]).destroy
    redirect_to issues_path
  end

  def link_contribution
    update_contribution( params[:id], params[:contribution_id] )
  end

  def unlink_contribution
    update_contribution params[:id], nil
  end

  def print
    @issue = Issue.find(params[:id])
    set_attachments(@issue.id)
    set_comments(@issue.id)
  end

  def tag
    @issue = Issue.find(params[:id])
  end

  def ajax_untag
    @issue = Issue.find(params[:id])
    tag = Tag.first(:conditions => {:name => params[:tag_name],
        :contract_id => @issue.contract_id})
    @issue.tags = @issue.tags - [tag]
    @issue.save!
    head :ok
  end

  def ajax_add_tag
    @issue = Issue.find(params[:id])
    tag = Tag.find_or_create_with_like_by_name_and_contract_id(params[:tag_name],
      @issue.contract_id)
    @issue.tags << tag
    @issue.save!
    render :partial => "issues/tags/show_tags"
  end

  def ajax_subscribe
    Subscription.create(:user => @session_user,
      :model => Issue.find(params[:id]))
    _panel_subscribers
    render :partial => 'issues/panel/panel_subscribers', :layout => false
  end

  def ajax_unsubscribe
    Subscription.destroy_by_user_and_model(@session_user,
      Issue.find(params[:id]))
    _panel_subscribers
    render :partial => 'issues/panel/panel_subscribers', :layout => false
  end

  def ajax_subscribe_someone
    res = Subscription.create(:user_id => params[:user_id],
      :model => Issue.find(params[:id]))
    head(res ? :ok : :error)
  end

  private
  def update_contribution( demand_id , contribution_id )
    if contribution_id == nil
      flash_text = _("This issue is no longer linked to a contribution")
    else
      flash_text = _("This contribution is now linked")
    end
    @issue = Issue.find(demand_id) unless @issue
    @issue.update_attributes!(:contribution_id => contribution_id)
    flash[:notice] = flash_text
    redirect_to issue_path(demand_id)
  end

  def _panel_subscribers
    if @session_user.engineer?
      @issue ||= Issue.find(params[:id])
      @engineers_subscribers =
        User.find_select_engineers_by_contract_id(@issue.contract_id)
    end
  end

  def _panel
    @statuts = Statut.find_select(:order => 'id')
    @issuetypes = Issuetype.find_select
    @severities = Severity.find_select
    if @session_user.engineer?
      @contracts = _panel_build_contracts
      @engineers = [[ _('[ Me ]'), @session_user.id ]].concat(
        User.find_select(User::EXPERT_OPTIONS))
    end
  end

  # Used to fill @contracts with various expert contracts associations
  def _panel_build_contracts
    contracts = []
    team = @session_user.team
    team_contract_ids = team.contract_ids if team
    if team and !team_contract_ids.empty?
      contracts.concat [[ _('[ Team ]'), team_contract_ids.to_json ]]
    end
    managed_contract_ids = @session_user.managed_contract_ids
    unless managed_contract_ids.empty?
      contracts.concat [[ _('[ Tam ]'), managed_contract_ids.to_json ]]
    end
    contracts.concat Contract.find_select(Contract::OPTIONS)
  end


  # Take an ActiveRecord Contract in parameter
  # Returns false if the Contract is not complete
  # call it like this : _form4contract Contract.first
  def _form4contract(contract)
    result = true
    @recipients = contract.find_recipients_select
    result = false if @recipients.empty?
    @softwares = contract.softwares.collect { |l| [ l.name, l.id ] }
    if @session_user.engineer?
      @engineers = User.find_select_by_contract_id(contract.id)
      @teams = Team.on_contract_id(contract.id)
    end
    result
  end

  def _form4versions
    software_id, contract_id = @issue.software_id.to_i, @issue.contract_id.to_i
    if software_id == 0 || contract_id == 0
      @versions = []
    else
      software = Software.find(software_id)
      contract = Contract.find(contract_id)

      @versions = software.releases_contract(contract.id).collect do |r|
        id = (r.type == Version ? "v#{r.id}" : "r#{r.id}")
        if ((@issue.version_id == r.id && r.type.is_a?(Version)) ||
              (@issue.release_id == r.id && r.type.is_a?(Release)))
          @selected_version = id
        end
        [ r.name, id ]
      end
    end
  end

  #TODO : redo
  def _form(recipient)
    @contracts = Contract.find_active4select(Contract::OPTIONS)
    if @contracts.empty?
      flash[:warn] = _("It seems that you are not associated to a contract, which prevents you from filling an issue. Please contact %s if you think it's not normal") % App::TeamEmail
      return redirect_to(welcome_path)
    end
    if recipient and recipient.recipient?
      client = recipient.client
      @issuetypes = client.issuetypes.collect{|td| [td.name, td.id]}
    else
      @engineers = User.find_select(User::EXPERT_OPTIONS)
      @issuetypes = Issuetype.find_select
    end
    _form4versions
    @severities = Severity.find_select
    first_comment = @issue.first_comment
    @issue.description = first_comment.text if first_comment
    @issue.recipient = recipient if recipient
    if @issue.contract
      _form4contract(@issue.contract)
    elsif !@contracts.empty?
      Contract.all.each { |c|
        if _form4contract(c)
          @issue.contract = c
          break
        end
      }
    end
  end

  def redirect_to_comment
    redirect_to issue_path(@issue)
  end

  def set_attachments(issue_id)
    options = { :conditions => filter_comments(issue_id), :order =>
        'comments.updated_on DESC', :include => [:comment] }
    @attachments = Attachment.all(options)
  end

  def set_comments(issue_id)
    fragment = "issues/#{issue_id}/comments-#{@session_user.kind}"
    if action_name == 'print' || !read_fragment(fragment)
      @comments = Comment.all(:conditions =>
          filter_comments(issue_id), :order => "created_on ASC",
        :include => [:user,:statut,:severity])
    end
  end

  # Private comments & attachments should not be read by recipients
  def filter_comments(issue_id)
    if @session_user.engineer?
      [ 'comments.issue_id = ?', issue_id ]
    else
      [ 'comments.issue_id = ? AND comments.private = ? ', issue_id, false ]
    end
  end

  # A small helper which set current flow filters
  # for index view
  def active_filters(value)
    case value
    when '1'
      @title = _('Active issues')
      Issue::OPENED
    when '-1'
      @title = _('Finished issues')
      Issue::CLOSED
    else
      nil
    end
  end

  # define what is a similar issue.
  # Used during create.
  # It *just* returns a correct path.
  def _similar_issue
    options = { :issue => {} }
    issue = options[:issue]
    Issue.remanent_fields.each { |f|
      value = @issue.send(f)
      issue[f] = value unless value.blank? || value == 0
    }
    new_issue_path(options)
  end

end
