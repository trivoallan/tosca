
#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  helper :filters, :contributions, :logiciels, :export, :appels,
    :socles, :commentaires, :account

  def en_attente
    options = { :per_page => 10, :order => 'updated_on DESC',
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = [ [ ] ]

    options[:joins] += 'INNER JOIN commentaires ON commentaires.id = demandes.last_comment_id'
    conditions.first << 'demandes.statut_id IN (?)'
    conditions << Statut::OPENED

    conditions.first << '(demandes.expected_on > NOW() OR (demandes.expected_on IS NULL AND commentaires.identifiant_id != ?))'
    conditions << session[:user].id

    if @ingenieur
      conditions.first << '(demandes.ingenieur_id = ? AND demandes.statut_id <> 3)'
      conditions << @ingenieur.id
    elsif @beneficiaire
      conditions.first << 'demandes.beneficiaire_id = ?'
      conditions << @beneficiaire.id
    end
    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    Demande.without_include_scope(@ingenieur, @beneficiaire) do
      @demande_pages, @demandes = paginate :demandes, options
    end

    render :template => 'demandes/lists/tobd' 
  end

  def index
    #special case : direct show
    if params.has_key? 'numero'
      redirect_to comment_demande_path(params['numero']) and return
    end

    options = { :per_page => 10, :order => 'updated_on DESC',
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
        [:text, 'logiciels.nom', 'demandes.resume', :dual_like ],
        [:client_id, 'beneficiaires.client_id', :equal ],
        [:ingenieur_id, 'demandes.ingenieur_id', :equal ],
        [:typedemande_id, 'demandes.typedemande_id', :equal ],
        [:severite_id, 'demandes.severite_id', :equal ],
        [:statut_id, 'demandes.statut_id', :equal ]
      ], special_cond)
      @filters = requests_filters
    end

    flash[:conditions] = options[:conditions] = conditions if conditions

    Demande.without_include_scope(@ingenieur, @beneficiaire) do
      @demande_pages, @demandes = paginate :demandes, options
    end

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
    @demande = Demande.new unless @demande
    _form @beneficiaire

    # check if the form can display
    if @contrats.empty?
      flash[:warn] = _("You are not linked to any contracts in our database.") +
        '<br />' << _("If you think it's an error, contact us at %s or at %s.") %
        [ Metadata::CONTACT_PHONE, Metadata::CONTACT_MAIL ]
      redirect_to(demandes_path) and return
    end

    # self-assign by default
    @demande.ingenieur = @ingenieur
    # without severity, by default
    @demande.severite_id = 4
    # self-contract, by default
    @demande.contrat_id = @contrats.first.id if @contrats.size == 1
    # statut "prise en compte" si ingénieur, sinon : "enregistrée"
    @demande.statut_id = (@ingenieur ? 2 : 1)
    # if we came from software view, it's sets automatically
    @demande.logiciel_id = params[:logiciel_id]

    @demande.beneficiaire_id = @beneficiaire.id if @beneficiaire
  end

  def create
    @demande = Demande.new(params[:demande])
    if @demande.save
      flash[:notice] = _("Your request has been successfully submitted")
      attachment = params[:piecejointe]
      unless attachment.blank?
        piecejointe = Piecejointe.create(:file => attachment[:file])
        @demande.first_comment.update_attribute(:piecejointe, piecejointe)
      end
      @commentaire = @demande.first_comment
      url_attachment = render_to_string(:layout => false, 
                                        :template => '/attachment')
      options = { :demande => @demande, :url_request => demande_url(@demande),
        :nom => session[:user].nom, :url_attachment => url_attachment }
      Notifier::deliver_request_new(options, flash)
      redirect_to demandes_path
    else
      _form @beneficiaire
      render :action => 'new'
    end
  end

  # Used when submitting new request, in order to select
  # packages which are subjects to SLA.
  def ajax_display_packages
    @demande = Demande.new(params[:demande])

    begin
      beneficiaire = Beneficiaire.find @demande.beneficiaire_id
      contrat = Contrat.find :first, :conditions =>
        ['contrats.client_id = ?', beneficiaire.client_id ]
      logiciel = Logiciel.find(@demande[:logiciel_id])
    rescue  ActiveRecord::RecordNotFound
      @paquets = []
    else
      # active = 1 : we only take supported packages.
      # MySQL doesn't support true/false so Rails use Tinyint...
      conditions = { :conditions =>
        [ 'paquets.logiciel_id=? AND paquets.active=1', logiciel.id ],
        :order => 'paquets.nom DESC' }
      @paquets = beneficiaire.client.paquets.find(:all, conditions)
    end
  end

  def edit
    @demande = Demande.find(params[:id])
    _form @beneficiaire
  end

  def comment
    @demande = Demande.find(params[:id]) unless @demande
    conditions = [ "logiciel_id = ?", @demande.logiciel_id ]
    # TODO c'est pas dry, cf ajax_comments
    options = { :order => 'created_on DESC', :include => [:identifiant],
      :limit => 1, :conditions => { :demande_id => @demande.id } }
    options[:conditions][:prive] = false if @beneficiaire
    @last_commentaire = Commentaire.find(:first, options)

    flash.now[:warn] = Metadata::DEMANDE_NOSTATUS unless @demande.statut

    @statuts = @demande.statut.possible(@beneficiaire)
    options =  { :conditions =>
      ['contributions.logiciel_id = ?', @demande.logiciel_id ] }
    @contributions = Contribution.find(:all, options)
    @severity = Severite.find(:all)

    @ingenieurs = Ingenieur.find_select_by_contrat_id(@demande.contrat_id)
    set_comments(@demande.id)

    @partial_for_summary = 'infos_demande'
    # render is mandatory becoz' of the alias with 'show'
    render :action => 'comment'
  end

  alias_method :show, :comment

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
    conditions = [ 'appels.demande_id = ? ', @demande_id ]
    options = { :conditions => conditions, :order => 'appels.debut',
      :include => [:beneficiaire,:ingenieur,:contrat,:demande] }
    @appels = Appel.find(:all, options)
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
      redirect_to comment_demande_path(@demande)
    else
      _form @beneficiaire
      render :action => 'edit'
    end
  end

  def destroy
    Demande.find(params[:id]).destroy
    redirect_to demandes_path
  end

  # TODO : enlever cette méthode quand elle passera dans le commentaire.
#   def changer_ingenieur
#     return render(:text => '') unless params.has_key? :id and params[:ingenieur_id]
#     @demande = Demande.find(params[:id])
#     @demande.ingenieur = Ingenieur.find(params[:ingenieur_id].to_i)
#     @demande.save!
#     if @demande.ingenieur
#       flash[:notice] = _("The request is correctly assigned")
#       options = {:demande => @demande, :controller => self}
#       Notifier::deliver_demande_assigner(options, flash)
#     else
#       flash[:notice] = _("The request is no more assigned")
#     end
#     redirect_to_comment
#   end

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
    redirect_to comment_demande_path(demand_id)
  end

  def _panel
    @statuts = Statut.find_select(:order => 'id')
    @typedemandes = Typedemande.find_select()
    @severites = Severite.find_select()
    if @ingenieur
      @clients = Client.find_select()
      @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    end
  end

  # todo à retravailler
  def _form(beneficiaire)
    @socles = Socle.find_select
    @contrats = Contrat.find_select
    if beneficiaire
      client = beneficiaire.client
      if client.support_distribution
        @logiciels = Logiciel.find_select
      else
        @logiciels = client.logiciels
      end
      @typedemandes = client.typedemandes
      @clients = [ client ]
    else
      @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
      @logiciels = Logiciel.find_select
      @typedemandes = Typedemande.find_select
      @clients = Client.find_select(Client::SELECT_OPTIONS)
    end
    @severites = Severite.find_select
  end

  def redirect_to_comment
    redirect_to comment_demande_path(@demande)
  end

  def set_piecejointes(demande_id)
    conditions = [ 'commentaires.demande_id = ? ', demande_id ]
    options = { :conditions => conditions, :order =>
      'commentaires.updated_on DESC', :include => [:commentaire] }
    @piecejointes = Piecejointe.find(:all, options)
  end

  def set_comments(demande_id)
    unless @last_commentaire
      if @ingenieur
        @commentaires = Commentaire.find(:all, :conditions =>
         [ 'commentaires.demande_id = ?', demande_id ],
         :order => "created_on ASC", :include => [:identifiant,:statut,:severite])
      else
        @commentaires = Commentaire.find(:all, :conditions =>
         [ 'commentaires.demande_id = ? AND commentaires.prive = ? ',
           demande_id, false ],
         :order => 'created_on ASC', :include => [:identifiant,:statut,:severite])
      end
    end

    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    select = "DISTINCT identifiants.id "
    @identifiants_ingenieurs = Identifiant.find(:all,
       :select => select, :joins => joins).collect{|i| i.id }
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
