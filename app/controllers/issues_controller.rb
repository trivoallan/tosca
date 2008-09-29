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
class IssuesController < ApplicationController
  helper :filters, :contributions, :softwares, :phonecalls,
    :socles, :comments, :account, :reporting, :links

  cache_sweeper :issue_sweeper, :only =>
    [:create, :update, :destroy, :link_contribution, :unlink_contribution]

  def pending
    options = { :order => 'updated_on DESC',
      :select => Issue::SELECT_LIST, :joins => Issue::JOINS_LIST }
    conditions = [ [ ] ]

    options[:joins] += 'INNER JOIN comments ON comments.id = issues.last_comment_id'

    conditions.first << 'issues.statut_id IN (?)'
    conditions << Statut::OPENED
    conditions.first << '(issues.expected_on < NOW() OR issues.expected_on IS NULL)'

    if @ingenieur
      conditions.first << 'issues.ingenieur_id IN (?)'
    elsif @recipient
      conditions.first << 'issues.recipient_id IN (?)'
    end
    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    own_id = (@ingenieur ? @ingenieur.id : @recipient.id)
    conditions << [ own_id ]
    @own_issues = Issue.find(:all, options)

    # Update last condition to the whole team
    if @ingenieur
      team = session[:user].team
      conditions[-1] = (team ? team.engineers_id : [])
    elsif @recipient
      conditions[-1] = @recipient.client.recipient_ids
    end
    # It's better to not display twice same issue
    conditions[-1].delete(own_id)

    @team_issues = Issue.find(:all, options)

    render :template => 'issues/lists/pending'
  end

  # Track of renewed issue is done with expected_on
  # visual effects are in js.erb view
  def ajax_renew
    expected_on, @issue_ids = params[:expected_on].to_i, params[:issue_ids]
    return if expected_on <= 0 || @issue_ids.empty?
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
    @title = _('All the issues')

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
        [:text, 'softwares.name', 'issues.resume', :dual_like ],
        [:contract_id, 'issues.contract_id', :equal ],
        [:ingenieur_id, 'issues.ingenieur_id', :equal ],
        [:typeissue_id, 'issues.typeissue_id', :equal ],
        [:severite_id, 'issues.severite_id', :equal ],
        [:statut_id, 'issues.statut_id', :equal ]
      ], special_cond)
      @filters = issues_filters
    end
    options = { :per_page => per_page, :order => order,
      :select => Issue::SELECT_LIST, :joins => Issue::JOINS_LIST }

    flash[:conditions] = options[:conditions] = conditions if conditions

    @issue_pages, @issues = paginate :issues, options

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'issues/lists/issues_list', :layout => false
    else
      _panel
      @partial_for_summary = 'issues/lists/issues_info'
      render :template => 'issues/lists/index'
    end
  end

  def new
    unless @issue
      @issue = Issue.new(params.has_key?(:issue) ? params[:issue] : nil)
    end
    _form @recipient

    @issue.statut_id = (@ingenieur ? 2 : 1)
    unless params.has_key? :issue
      @issue.set_defaults(@ingenieur, @recipient, params)
    end
  end

  def create
    @issue = Issue.new(params[:issue])
    user = session[:user]
    @issue.submitter = user # it's the current user
    @issue.statut_id = (@ingenieur ? 2 : 1)
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
      url_attachment = render_to_string(:layout => false,
                                        :template => '/attachment')
      options = { :issue => @issue,
        :url_issue => issue_url(@issue),
        :name => user.name, :url_attachment => url_attachment }

      Notifier::deliver_issue_new(options, flash)
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
    issue = params[:issue]
    contract_id = issue[:contract_id]
    software_id = issue[:software_id]
    if software_id.blank? or contract_id.blank?
      @versions = []
    else
      software = Software.find(software_id)
      contract = Contract.find(contract_id)

      @versions = software.releases_contract(contract.id).collect do |r|
        #case...when seems not to work
        if r.type == Version
          id = "v#{r.id}"
        elsif r.type == Release
          id = "r#{r.id}"
        end
        [ r.name, id ]
      end
    end
  end

  def edit
    @issue = Issue.find(params[:id])
    _form @recipient
  end

  def show
    @issue = Issue.find(params[:id], :include => [:first_comment]) unless @issue
    @page_title = @issue.resume
    @partial_for_summary = 'infos_issue'
    unless read_fragment "issues/#{@issue.id}/front-#{session[:user].role_id}"
      @comment = Comment.new(:elapsed => 1, :issue => @issue)
      @comment.text = flash[:old_body] if flash.has_key? :old_body

      # TODO c'est pas dry, cf ajax_comments
      options = { :order => 'created_on DESC', :include => [:user],
        :limit => 1, :conditions => { :issue_id => @issue.id } }
      options[:conditions][:private] = false if @recipient
      @last_comment = Comment.find(:first, options)

      @statuts = @issue.statut.possible(@recipient)
      options =  { :order => 'updated_on DESC', :limit => 10, :conditions =>
        [ 'contributions.software_id = ?', @issue.software_id ] }
      @contributions = Contribution.find(:all, options).collect{|c| [c.name, c.id]} || []
      if @ingenieur
        @severites = Severite.find_select
        @ingenieurs = Ingenieur.find_select_by_contract_id(@issue.contract_id)
        @teams = Team.on_contract_id(@issue.contract_id)
      end
    end
  end

  def ajax_description
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue = Issue.find(params[:id]) unless @issue
    render :partial => 'issues/tabs/tab_description', :layout => false
  end

  def ajax_comments
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue_id = params[:id]
    set_comments(@issue_id)
    render :partial => "issues/tabs/tab_comments", :layout => false
  end

  def ajax_history
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue_id = params[:id]
    unless read_fragment "issues/#{@issue_id}/history"
      @last_comment = nil # Prevents some insidious call with functionnal tests
      conditions = filter_comments(@issue_id)
      conditions[0] << " AND statut_id IS NOT NULL"
      @comments = Comment.find(:all, :conditions => conditions,
        :order => "created_on ASC", :include => [:user,:statut,:severite])
    end
    render :partial => 'issues/tabs/tab_history', :layout => false
  end

  def ajax_phonecalls
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue_id = params[:id]
    conditions = [ 'phonecalls.issue_id = ? ', @issue_id ]
    options = { :conditions => conditions, :order => 'phonecalls.start',
      :include => [:recipient,:ingenieur,:contract,:issue] }
    @phonecalls = Phonecall.find(:all, options)
    render :partial => 'issues/tabs/tab_phonecalls', :layout => false
  end

  def ajax_attachments
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @issue_id = params[:id]
    set_attachments(@issue_id)
    render :partial => 'issues/tabs/tab_attachments', :layout => false
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
      _form @recipient
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

  private
  def update_contribution( demand_id , contribution_id )
    if contribution_id == nil
      flash_text = _("The demand has now no contribution")
    else
      flash_text = _("This contribution is now linked")
    end
    @issue = Issue.find(demand_id) unless @issue
    @issue.update_attributes!(:contribution_id => contribution_id)
    flash[:notice] = flash_text
    redirect_to issue_path(demand_id)
  end

  def _panel
    @statuts = Statut.find_select(:order => 'id')
    @typeissues = Typeissue.find_select()
    @severites = Severite.find_select()
    if @ingenieur
      @contracts = Contract.find_select(Contract::OPTIONS)
      @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  # Take an ActiveRecord Contract in parameter
  # Returns false if the Contract is not complete
  # call it like this : _form4contract Contract.find(:first)
  def _form4contract(contract)
    result = true
    @recipients = contract.find_recipients_select
    result = false if @recipients.empty?
    @versions = []
    @softwares = contract.softwares.collect { |l| [ l.name, l.id ] }
    if @ingenieur
      @ingenieurs = Ingenieur.find_select_by_contract_id(contract.id)
      @teams = Team.on_contract_id(contract.id)
    end
    result
  end

  #TODO : redo
  def _form(recipient)
    @contracts = Contract.find_active4select(Contract::OPTIONS)
    if @contracts.empty?
      flash[:warn] = _("It seems that you are not associated to a contract, which prevents you from filling an issue. Please contact %s if you think it's not normal") % App::TeamEmail
      return redirect_to(welcome_path)
    end
    if recipient
      client = recipient.client
      @typeissues = client.typeissues.collect{|td| [td.name, td.id]}
    else
      @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
      @typeissues = Typeissue.find_select
    end
    @versions = []
    @severites = Severite.find_select
    first_comment = @issue.first_comment
    @issue.description = first_comment.text if first_comment
    @issue.recipient = recipient if recipient
    if @issue.contract
      _form4contract(@issue.contract)
    elsif !@contracts.empty?
      Contract.find(:all).each { |c|
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
    @attachments = Attachment.find(:all, options)
  end

  def set_comments(issue_id)
    fragment = "issues/#{issue_id}/comments-#{session[:user].kind}"
    if action_name == 'print' || !read_fragment(fragment)
      @comments = Comment.find(:all, :conditions =>
        filter_comments(issue_id), :order => "created_on ASC",
        :include => [:user,:statut,:severite])
    end
  end

  # Private comments & attachments should not be read by recipients
  def filter_comments(issue_id)
    if @ingenieur
      [ 'comments.issue_id = ?', issue_id ]
    else
      [ 'comments.issue_id = ? AND comments.private = 0 ', issue_id ]
    end
  end

  # A small helper which set current flow filters
  # for index view
  def active_filters(value)
    case value
    when '1'
      @title = _('Active issues')
      Issue::EN_COURS
    when '-1'
      @title = _('Finished issues')
      Issue::TERMINEES
    else
      nil
    end
  end

  # define what is a similar issue.
  # Used during create.
  # It *just* returns a correct path.
  def _similar_issue
    options = { :issue => Hash.new }
    issue = options[:issue]
    Issue.remanent_fields.each { |f|
      value = @issue.send(f)
      issue[f] = value unless value.blank? || value == 0
    }
    new_issue_path(options)
  end

end

#<%= observe_form "issue_form",
# {:url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :frequency => 15 } %>
#<%= observe_field "issue_severite_id", {
#  :url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :with => "severite_id" }
#%>
#<%= observe_field "issue_software_id",
# {:url => {:action => :ajax_update_versions},
#  :update => :issue_versions,
#  :with => "software_id"} %>
