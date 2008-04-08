#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  helper :filters, :contributions, :logiciels, :export, :phonecalls,
    :socles, :commentaires, :account, :reporting

  cache_sweeper :demande_sweeper, :only => [:create, :update, :destroy]


  def en_attente
    options = { :per_page => 10, :order => 'updated_on DESC',
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = [ [ ] ]

    options[:joins] += 'INNER JOIN commentaires ON commentaires.id = demandes.last_comment_id'

    conditions.first << 'demandes.statut_id IN (?)'
    conditions << Statut::OPENED
    conditions.first << '(demandes.expected_on > NOW() OR demandes.expected_on IS NULL)'

    # find request where :
    # 1. Engineer : When SLA is running Or SLA is suspended  and ( a question from the recipient is not answered OR he just has been assigned )
    # 2. Recipient : When a question from the engineer is not answered
    if @ingenieur # 3 == Suspendue
      conditions.first << ('(demandes.statut_id <> 3 OR (demandes.statut_id = 3 AND ' +
               '(commentaires.user_id = beneficiaires.user_id OR commentaires.ingenieur_id IS NOT NULL) ) )' )
    else
      conditions.first << '(demandes.statut_id = 3 AND commentaires.user_id <> beneficiaires.user_id)'
    end

    if @ingenieur
      conditions.first << 'demandes.ingenieur_id = ?'
      conditions << @ingenieur.id
    elsif @beneficiaire
      conditions.first << 'demandes.beneficiaire_id = ?'
      conditions << @beneficiaire.id
    else
      throw Exception.new("unidentified")
    end

    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    @demande_pages, @demandes = paginate :demandes, options

    render :template => 'demandes/lists/tobd'
  end

  def index
    #special case : direct show
    if params.has_key? 'numero'
      redirect_to demande_path(params['numero'].first.to_i) and return
    end

    order = params[:sort] || 'updated_on DESC'
    options = { :per_page => 10, :order => order,
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = []

    # Specification of a filter f :

    if params.has_key? :filters
      session[:requests_filters] = Filters::Requests.new(params[:filters])
    end

    conditions = nil
    @title = _('All the requests')

    if session.data.has_key? :requests_filters
      requests_filters = session[:requests_filters]

      # Here is the trick for the "flow" part of the view
      special_cond = active_filters(requests_filters[:active])

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(requests_filters, [
        [:text, 'logiciels.name', 'demandes.resume', :dual_like ],
        [:client_id, 'beneficiaires.client_id', :equal ],
        [:ingenieur_id, 'demandes.ingenieur_id', :equal ],
        [:typedemande_id, 'demandes.typedemande_id', :equal ],
        [:severite_id, 'demandes.severite_id', :equal ],
        [:statut_id, 'demandes.statut_id', :equal ]
      ], special_cond)
      @filters = requests_filters
    end

    flash[:conditions] = options[:conditions] = conditions if conditions

    @demande_pages, @demandes = paginate :demandes, options

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :partial => 'demandes/lists/requests_list', :layout => false
    else
      _panel
      @partial_for_summary = 'demandes/lists/requests_info'
      render :template => 'demandes/lists/index'
    end
  end

  def new
    unless @demande
      @demande = Demande.new(params.has_key?(:demande) ? params[:demande] : nil)
    end
    _form @beneficiaire

    @demande.statut_id = (@ingenieur ? 2 : 1)
    unless params.has_key? :demande
      @demande.set_defaults(@ingenieur, @beneficiaire, @contrats, params)
    end
  end

  def create
    @demande = Demande.new(params[:demande])
    @demande.submitter = session[:user] # it's the current user
    @demande.statut_id = (@ingenieur ? 2 : 1)
    if @demande.contrat.nil? && @demande.submitter.contrats.size == 1
      @demande.contrat = session[:user].contrats.first
    end
    if @demande.save
      options = { :conditions => [ 'demandes.submitter_id = ?', session[:user].id ]}
      flash[:notice] = _("You have successfully submitted your %s request.") %
        Demande.count(options).ordinalize
      @demande.first_comment.add_attachment(params)
      @comment = @demande.first_comment
      # needed in order to send properly the email
      @demande.first_comment.demande.reload
      url_attachment = render_to_string(:layout => false,
                                        :template => '/attachment')
      options = { :demande => @demande, :url_request => demande_url(@demande),
        :name => session[:user].name, :url_attachment => url_attachment }
      Notifier::deliver_request_new(options, flash)
      redirect_to _similar_request
    else
      _form @beneficiaire
      render :action => 'new'
    end
  end

  # Used when submitting new request, in order to select
  # packages which are subjects to SLA.
  def ajax_display_commitment
    return render(:nothing => true) unless params.has_key? :demande
    @demande = Demande.new(params[:demande])
  end

  # Used when submitting new request, in order to select
  # correct contracts
  def ajax_display_contract
    return render(:nothing => true) unless params.has_key? :contrat_id
    contrat = Contrat.find(params[:contrat_id].to_i)
    _form4contract(contrat)
  end

  # Used when submitting new request, in order to select
  # correct version of a software
  def ajax_display_version
    return render(:nothing => true) unless params.has_key? :demande
    request = params[:demande]
    logiciel_id = request[:logiciel_id]
    socle_id = request[:socle_id]
    if logiciel_id.blank? || socle_id.blank?
      @binaires = []
    else
      logiciel = Logiciel.find(logiciel_id.to_i)
      options = { :conditions => ['binaires.socle_id = ?', socle_id.to_i]}
      bins = logiciel.binaires
      @binaires = bins.find_select(options)
    end
  end


  def edit
    @demande = Demande.find(params[:id])
    _form @beneficiaire
  end

  def show
    @demande = Demande.find(params[:id], :include => [:first_comment]) unless @demande
    conditions = [ "logiciel_id = ?", @demande.logiciel_id ]
    # TODO c'est pas dry, cf ajax_comments
    options = { :order => 'created_on DESC', :include => [:user],
      :limit => 1, :conditions => { :demande_id => @demande.id } }
    options[:conditions][:prive] = false if @beneficiaire
    @last_commentaire = Commentaire.find(:first, options)

    @statuts = @demande.statut.possible(@beneficiaire)
    options =  { :order => 'updated_on DESC', :limit => 10, :conditions =>
      ['contributions.logiciel_id = ?', @demande.logiciel_id ] }
    @contributions = Contribution.find(:all, options).collect{|c| [c.name, c.id]}
    if @ingenieur
      @severites = Severite.find_select
      @ingenieurs = Ingenieur.find_select_by_contrat_id(@demande.contrat_id)
    end
    set_comments(@demande.id)

    @partial_for_summary = 'infos_demande'

    @commentaire = Commentaire.new(:elapsed => 1, :demande => @demande)
    @commentaire.corps = flash[:old_body] if flash.has_key? :old_body
  end

  def ajax_description
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'demandes/tabs/tab_description', :layout => false
  end

  def ajax_comments
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande_id = params[:id]
    set_comments(@demande_id)
    render :partial => "demandes/tabs/tab_comments", :layout => false
  end

  def ajax_history
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande_id = params[:id]
    set_comments(@demande_id)
    render :partial => 'demandes/tabs/tab_history', :layout => false
  end

  def ajax_appels
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande_id = params[:id]
    conditions = [ 'phonecalls.demande_id = ? ', @demande_id ]
    options = { :conditions => conditions, :order => 'phonecalls.start',
      :include => [:beneficiaire,:ingenieur,:contrat,:demande] }
    @phonecalls = Phonecall.find(:all, options)
    render :partial => 'demandes/tabs/tab_appels', :layout => false
  end

  def ajax_piecejointes
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande_id = params[:id]
    set_piecejointes(@demande_id)
    render :partial => 'demandes/tabs/tab_piecejointes', :layout => false
  end

  def ajax_cns
    return render(:text => '') unless request.xhr? and params.has_key? :id
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'demandes/tabs/tab_cns', :layout => false
  end

  def update
    @demande = Demande.find(params[:id])
    @demande.paquets = Paquet.find(params[:paquet_ids]) if params[:paquet_ids]
    if @demande.update_attributes(params[:demande])
      flash[:notice] = _("The request has been updated successfully.")
      redirect_to demande_path(@demande)
    else
      _form @beneficiaire
      render :action => 'edit'
    end
  end

  def destroy
    Demande.find(params[:id]).destroy
    redirect_to demandes_path
  end

  def associer_contribution
    update_contribution( params[:id], params[:contribution_id] )
  end

  def delete_contribution
    update_contribution params[:id], nil
  end

  def print
    @demande = Demande.find(params[:id])
    set_piecejointes(@demande.id)
    set_comments(@demande.id)
  end

  private
  def update_contribution( demand_id , contribution_id )
    if contribution_id == nil
      flash_text = _("The demand has now no contribution")
    else
      flash_text = _("This contribution is now linked")
    end
    @demande = Demande.find(demand_id) unless @demande
    @demande.update_attributes!(:contribution_id => contribution_id)
    flash[:notice] = flash_text
    redirect_to demande_path(demand_id)
  end

  def _panel
    @statuts = Statut.find_select(:order => 'id')
    @typedemandes = Typedemande.find_select()
    @severites = Severite.find_select()
    if @ingenieur
      @clients = Client.find_select()
      @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  def _form4contract(contrat)
    @beneficiaires = contrat.find_recipients_select
    @socles = contrat.client.socles
    @logiciels = contrat.logiciels.collect{|l| [l.name, l.id] }
    if @ingenieur
      @ingenieurs = Ingenieur.find_select_by_contrat_id(contrat.id)
    end
  end

  # todo à retravailler
  def _form(beneficiaire)
    @contrats = Contrat.find_select(Contrat::OPTIONS)
    if beneficiaire
      client = beneficiaire.client
      @typedemandes = client.typedemandes.collect{|td| [td.name, td.id]}
    else
      @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
      @typedemandes = Typedemande.find_select
      options = { :include => { :beneficiaires => :user}, :conditions =>
        'clients.inactive = 0' }
    end
    @binaires = []
    @severites = Severite.find_select
    first_comment = @demande.first_comment
    @demande.description = first_comment.corps if first_comment
    @demande.beneficiaire = beneficiaire
    contract = @demande.contrat || Contrat.find(:first)
    _form4contract contract
  end

  def redirect_to_comment
    redirect_to demande_path(@demande)
  end

  def set_piecejointes(demande_id)
    options = { :conditions => filter_comments(demande_id), :order =>
      'commentaires.updated_on DESC', :include => [:commentaire] }
    @piecejointes = Piecejointe.find(:all, options)
  end

  def set_comments(demande_id)
    unless @last_commentaire
      @commentaires = Commentaire.find(:all, :conditions =>
        filter_comments(demande_id), :order => "created_on ASC",
        :include => [:user,:statut,:severite])
    end
  end

  # Private comments & attachments should not be read by recipients
  def filter_comments(demande_id)
    if @ingenieur
      [ 'commentaires.demande_id = ?', demande_id ]
    else
      [ 'commentaires.demande_id = ? AND commentaires.prive = 0 ', demande_id ]
    end
  end

  # A small helper which set current flow filters
  # for index view
  def active_filters(value)
    case value
    when '1'
      @title = _('Active requests')
      Demande::EN_COURS
    when '-1'
      @title = _('Finished requests')
      Demande::TERMINEES
    else
      nil
    end
  end

  # define what is a similar request.
  # Used during create.
  # It _just_ returns a correct path.
  def _similar_request
    options = { :demande => Hash.new }
    request = options[:demande]
    Demande.remanent_fields.each { |f|
      value = @demande.send(f)
      request[f] = value unless value.blank? || value == 0
    }
    new_demande_path(options)
  end

end

#<%= observe_form "demande_form",
# {:url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :frequency => 15 } %>
#<%= observe_field "demande_severite_id", {
#  :url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :with => "severite_id" }
#%>
#<%= observe_field "demande_logiciel_id",
# {:url => {:action => :ajax_update_paquets},
#  :update => :demande_paquets,
#  :with => "logiciel_id"} %>
