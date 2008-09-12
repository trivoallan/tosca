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
class RequestsController < ApplicationController
  helper :filters, :contributions, :logiciels, :phonecalls,
    :socles, :commentaires, :account, :reporting

  cache_sweeper :request_sweeper, :only =>
    [:create, :update, :destroy, :link_contribution, :unlink_contribution]

  def pending
    options = { :order => 'updated_on DESC',
      :select => Request::SELECT_LIST, :joins => Request::JOINS_LIST }
    conditions = [ [ ] ]

    options[:joins] += 'INNER JOIN commentaires ON commentaires.id = requests.last_comment_id'

    conditions.first << 'requests.statut_id IN (?)'
    conditions << Statut::OPENED
    conditions.first << '(requests.expected_on < NOW() OR requests.expected_on IS NULL)'

    if @ingenieur
      conditions.first << 'requests.ingenieur_id IN (?)'
    elsif @recipient
      conditions.first << 'requests.recipient_id IN (?)'
    end
    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    own_id = (@ingenieur ? @ingenieur.id : @recipient.id)
    conditions << [ own_id ]
    @own_requests = Request.find(:all, options)

    # Update last condition to the whole team
    if @ingenieur
      team = session[:user].team
      conditions[-1] = (team ? team.engineers_id : [])
    elsif @recipient
      conditions[-1] = @recipient.client.recipient_ids
    end
    # It's better to not display twice same request
    conditions[-1].delete(own_id)

    @team_requests = Request.find(:all, options)

    render :template => 'requests/lists/pending'
  end

  # Track of renewed request is done with expected_on
  # visual effects are in js.erb view
  def ajax_renew
    expected_on, @request_ids = params[:expected_on].to_i, params[:request_ids]
    return if expected_on <= 0 || @request_ids.empty?
    expected = Time.now + expected_on.days
    Request.find(@request_ids).each {|r|
      r.update_attribute(:expected_on, expected)
    }
  end

  def index
    #special case : direct show
    if params.has_key? 'numero'
      redirect_to request_path(params['numero'].first.to_i) and return
    end

    order = params[:sort] || 'updated_on DESC'

    # Specification of a filter f :
    if params.has_key? :filters
      session[:requests_filters] = Filters::Requests.new(params[:filters])
    end

    conditions = nil
    @title = _('All the requests')

    requests_filters = session[:requests_filters]

    # TODO : See if, with cache, no include is faster or not.
    # It has to be changed in the export controller too, for the request part
    per_page, conditions = 10, []
    if requests_filters
      # Here is the trick for the "flow" part of the view
      special_cond = active_filters(requests_filters[:active])

      # Asked by popular request
      limit = requests_filters[:limit].to_i
      per_page = limit if limit > 0

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(requests_filters, [
        [:text, 'logiciels.name', 'requests.resume', :dual_like ],
        [:contract_id, 'requests.contract_id', :equal ],
        [:ingenieur_id, 'requests.ingenieur_id', :equal ],
        [:typerequest_id, 'requests.typerequest_id', :equal ],
        [:severite_id, 'requests.severite_id', :equal ],
        [:statut_id, 'requests.statut_id', :equal ]
      ], special_cond)
      @filters = requests_filters
    end
    options = { :per_page => per_page, :order => order,
      :select => Request::SELECT_LIST, :joins => Request::JOINS_LIST }

    flash[:conditions] = options[:conditions] = conditions if conditions

    @request_pages, @requests = paginate :requests, options

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'requests/lists/requests_list', :layout => false
    else
      _panel
      @partial_for_summary = 'requests/lists/requests_info'
      render :template => 'requests/lists/index'
    end
  end

  def new
    unless @request_tosca
      @request_tosca = Request.new(params.has_key?(:request) ? params[:request] : nil)
    end
    _form @recipient

    @request_tosca.statut_id = (@ingenieur ? 2 : 1)
    unless params.has_key? :request
      @request_tosca.set_defaults(@ingenieur, @recipient, params)
    end
  end

  def create
    @request_tosca = Request.new(params[:request])
    user = session[:user]
    @request_tosca.submitter = user # it's the current user
    @request_tosca.statut_id = (@ingenieur ? 2 : 1)
    if @request_tosca.contract.nil?
      contracts = @request_tosca.recipient.contracts
      @request_tosca.contract = contracts.first if contracts.size == 1
    end

    revisions = params[:software][:revision_id] if params[:software]
    @request_tosca.associate_software(revisions)

    if @request_tosca.save
      options = { :conditions => [ 'requests.submitter_id = ?', user.id ]}
      flash[:notice] = _("You have successfully submitted your %s request.") %
        _ordinalize(Request.count(options))
      @request_tosca.first_comment.add_attachment(params)
      @comment = @request_tosca.first_comment
      # needed in order to send properly the email
      @request_tosca.first_comment.request.reload
      url_attachment = render_to_string(:layout => false,
                                        :template => '/attachment')
      options = { :request => @request_tosca, :url_request => request_url(@request_tosca),
        :name => user.name, :url_attachment => url_attachment }

      Notifier::deliver_request_new(options, flash)
      redirect_to _similar_request
    else
      _form @recipient
      render :action => 'new'
    end
  end

  # Used when submitting new request, in order to select
  # packages which are subjects to SLA.
  def ajax_display_commitment
    return render(:nothing => true) unless params.has_key? :request
    @request_tosca = Request.new(params[:request])
  end

  # Used when submitting new request, in order to select
  # correct contracts
  def ajax_display_contract
    return render(:nothing => true) unless params.has_key? :contract_id
    contract = Contract.find(params[:contract_id].to_i)
    _form4contract(contract)
  end

  # Used when submitting new request, in order to select
  # correct version of a software
  def ajax_display_version
    return render(:nothing => true) unless params.has_key? :request
    request = params[:request]
    contract_id = request[:contract_id]
    logiciel_id = request[:logiciel_id]
    if logiciel_id.blank? or contract_id.blank?
      @versions = []
    else
      logiciel = Logiciel.find(logiciel_id)
      contract = Contract.find(contract_id)

      @versions = logiciel.releases_contract(contract.id).collect do |r|
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
    @request_tosca = Request.find(params[:id])
    _form @recipient
  end

  def show
    @request_tosca = Request.find(params[:id], :include => [:first_comment]) unless @request_tosca
    @page_title = @request_tosca.resume
    @partial_for_summary = 'infos_request'
    unless read_fragment "requests/#{@request_tosca.id}/front-#{session[:user].role_id}"
      @commentaire = Commentaire.new(:elapsed => 1, :request => @request_tosca)
      @commentaire.corps = flash[:old_body] if flash.has_key? :old_body

      # TODO c'est pas dry, cf ajax_comments
      options = { :order => 'created_on DESC', :include => [:user],
        :limit => 1, :conditions => { :request_id => @request_tosca.id } }
      options[:conditions][:prive] = false if @recipient
      @last_commentaire = Commentaire.find(:first, options)

      @statuts = @request_tosca.statut.possible(@recipient)
      options =  { :order => 'updated_on DESC', :limit => 10, :conditions =>
        [ 'contributions.logiciel_id = ?', @request_tosca.logiciel_id ] }
      @contributions = Contribution.find(:all, options).collect{|c| [c.name, c.id]} || []
      if @ingenieur
        @severites = Severite.find_select
        @ingenieurs = Ingenieur.find_select_by_contract_id(@request_tosca.contract_id)
        @teams = Team.on_contract_id(@request_tosca.contract_id)
      end
    end
  end

  def ajax_description
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_tosca = Request.find(params[:id]) unless @request_tosca
    render :partial => 'requests/tabs/tab_description', :layout => false
  end

  def ajax_comments
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_id = params[:id]
    set_comments(@request_id)
    render :partial => "requests/tabs/tab_comments", :layout => false
  end

  def ajax_history
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_id = params[:id]
    unless read_fragment "requests/#{@request_id}/history"
      @last_commentaire = nil # Prevents some insidious call with functionnal tests
      conditions = filter_comments(@request_id)
      conditions[0] << " AND statut_id IS NOT NULL"
      @commentaires = Commentaire.find(:all, :conditions => conditions,
        :order => "created_on ASC", :include => [:user,:statut,:severite])
    end
    render :partial => 'requests/tabs/tab_history', :layout => false
  end

  def ajax_appels
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_id = params[:id]
    conditions = [ 'phonecalls.request_id = ? ', @request_id ]
    options = { :conditions => conditions, :order => 'phonecalls.start',
      :include => [:recipient,:ingenieur,:contract,:request] }
    @phonecalls = Phonecall.find(:all, options)
    render :partial => 'requests/tabs/tab_appels', :layout => false
  end

  def ajax_attachments
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_id = params[:id]
    set_attachments(@request_id)
    render :partial => 'requests/tabs/tab_attachments', :layout => false
  end

  def ajax_cns
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @request_tosca = Request.find(params[:id]) unless @request_tosca
    render :partial => 'requests/tabs/tab_cns', :layout => false
  end

  def update
    @request_tosca = Request.find(params[:id])
    @request_tosca.versions = Paquet.find(params[:version_ids]) if params[:version_ids]
    request = params[:request]
    # description is delocalized into the first comment, mainly for db perf.
    description = request[:description]
    if @request_tosca.update_attributes(request) &&
        @request_tosca.first_comment.update_attribute(:corps, description)
      flash[:notice] = _("The request has been updated successfully.")
      redirect_to request_path(@request_tosca)
    else
      _form @recipient
      render :action => 'edit'
    end
  end

  def destroy
    Request.find(params[:id]).destroy
    redirect_to requests_path
  end

  def link_contribution
    update_contribution( params[:id], params[:contribution_id] )
  end

  def unlink_contribution
    update_contribution params[:id], nil
  end

  def print
    @request_tosca = Request.find(params[:id])
    set_attachments(@request_tosca.id)
    set_comments(@request_tosca.id)
  end
  
  def tag
    @request_tosca = Request.find(params[:id])
  end
  
  def ajax_untag
    @request_tosca = Request.find(params[:id])
    @request_tosca.tag_list.remove(params[:tag_name])
    @request_tosca.save!
    head :ok
  end
  
  def ajax_add_tag
    @request_tosca = Request.find(params[:id])
    @request_tosca.tag_list.add(params[:tag_name])
    @request_tosca.save!
    render :partial => "requests/tags/show_tags"
  end

  private
  def update_contribution( demand_id , contribution_id )
    if contribution_id == nil
      flash_text = _("The demand has now no contribution")
    else
      flash_text = _("This contribution is now linked")
    end
    @request_tosca = Request.find(demand_id) unless @request_tosca
    @request_tosca.update_attributes!(:contribution_id => contribution_id)
    flash[:notice] = flash_text
    redirect_to request_path(demand_id)
  end

  def _panel
    @statuts = Statut.find_select(:order => 'id')
    @typerequests = Typerequest.find_select()
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
    @logiciels = contract.logiciels.collect { |l| [ l.name, l.id ] }
    if @ingenieur
      @ingenieurs = Ingenieur.find_select_by_contract_id(contract.id)
      @teams = Team.on_contract_id(contract.id)
    end
    result
  end

  #TODO : redo
  def _form(recipient)
    @contracts = Contract.find_select(Contract::OPTIONS)
    if @contracts.empty?
      flash[:warn] = _("It seems that you are not associated to a contract, which prevents you from filling a request. Please contact %s if you think it's not normal") % App::TeamEmail
      return redirect_to(welcome_path)
    end
    if recipient
      client = recipient.client
      @typerequests = client.typerequests.collect{|td| [td.name, td.id]}
    else
      @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
      @typerequests = Typerequest.find_select
    end
    @versions = []
    @severites = Severite.find_select
    first_comment = @request_tosca.first_comment
    @request_tosca.description = first_comment.corps if first_comment
    @request_tosca.recipient = recipient if recipient
    if @request_tosca.contract
      _form4contract(@request_tosca.contract)
    elsif !@contracts.empty?
      Contract.find(:all).each { |c|
        if _form4contract(c)
          @request_tosca.contract = c
          break
        end
      }
    end
  end

  def redirect_to_comment
    redirect_to request_path(@request_tosca)
  end

  def set_attachments(request_id)
    options = { :conditions => filter_comments(request_id), :order =>
      'commentaires.updated_on DESC', :include => [:commentaire] }
    @attachments = Attachment.find(:all, options)
  end

  def set_comments(request_id)
    fragment = "requests/#{request_id}/comments-#{session[:user].kind}"
    if action_name == 'print' || !read_fragment(fragment)
      @commentaires = Commentaire.find(:all, :conditions =>
        filter_comments(request_id), :order => "created_on ASC",
        :include => [:user,:statut,:severite])
    end
  end

  # Private comments & attachments should not be read by recipients
  def filter_comments(request_id)
    if @ingenieur
      [ 'commentaires.request_id = ?', request_id ]
    else
      [ 'commentaires.request_id = ? AND commentaires.prive = 0 ', request_id ]
    end
  end

  # A small helper which set current flow filters
  # for index view
  def active_filters(value)
    case value
    when '1'
      @title = _('Active requests')
      Request::EN_COURS
    when '-1'
      @title = _('Finished requests')
      Request::TERMINEES
    else
      nil
    end
  end

  # define what is a similar request.
  # Used during create.
  # It *just* returns a correct path.
  def _similar_request
    options = { :request => Hash.new }
    request = options[:request]
    Request.remanent_fields.each { |f|
      value = @request_tosca.send(f)
      request[f] = value unless value.blank? || value == 0
    }
    new_request_path(options)
  end

end

#<%= observe_form "request_form",
# {:url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :frequency => 15 } %>
#<%= observe_field "request_severite_id", {
#  :url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :with => "severite_id" }
#%>
#<%= observe_field "request_logiciel_id",
# {:url => {:action => :ajax_update_versions},
#  :update => :request_versions,
#  :with => "logiciel_id"} %>
