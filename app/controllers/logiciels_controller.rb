#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LogicielsController < ApplicationController
  # public access to the list
  skip_before_filter :login_required
  before_filter :login_required, :except => 
    [:list,:show,:auto_complete_for_logiciel_nom]

  helper :filters, :paquets, :demandes, :competences, :contributions
  
  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  POST_METHODS = [ :destroy, :create, :update, 
                   :auto_complete_for_logiciel_nom ]
  verify :method => :post, :only => POST_METHODS,
    :redirect_to => { :action => :list }


  def index
    list
    render :action => 'list'
  end

  # ajaxified list
  def list
    scope = nil
    @title= 'Liste des logiciels'
    if @beneficiaire
      unless params['active'] == '0'
        scope=:supported
        @title = 'Liste de vos logiciels'
      end

    end
    
    options = { :per_page => 10, :order => 'logiciels.nom',
      :include => [:groupe,:competences]}
    conditions = []

    # Dirty Hack. TODO : faire mieux
    filters = params['filters']
    if @ingenieur and filters and filters['client_id'] != ''
      filters['client_id'] = scope_client(filters['client_id'])
      options[:joins] = 'INNER JOIN paquets ON paquets.logiciel_id=logiciels.id' 
    end

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['logiciel', 'nom', 'logiciels.nom', :like ],
       ['logiciel', 'description', 'logiciels.description', :like ],
       ['filters', 'groupe_id', 'logiciels.groupe_id', :equal ],
       ['filters', 'competence_id', 'competences_logiciels.competence_id', :equal ],
       ['filters', 'client_id', ' paquets.contrat_id', :in ] 
     ])
    flash[:conditions] = options[:conditions] = conditions 

    # optional scope, for customers 
    Logiciel.set_scope(@beneficiaire.contrat_ids) if scope
    @logiciel_pages, @logiciels = paginate :logiciels, options
    Logiciel.remove_scope if scope

    # panel on the left side
    if request.xhr? 
      render :partial => 'softwares_list', :layout => false
    else
      _panel
      @partial_for_summary = 'softwares_info'
    end
  end

  def rpmlist
    @logiciels = Logiciel.find(:all)
  end

  def show
    @logiciel = Logiciel.find(params[:id])
    if @beneficiaire
      @demandes = @beneficiaire.demandes.find(:all, :conditions => 
                                              ['demandes.logiciel_id=?', params[:id]])
    else
      @demandes = Demande.find(:all, :conditions => 
                               ['demandes.logiciel_id=?',params[:id]])
    end
  end

  def card
    @logiciel = Logiciel.find(params[:id])
  end

  def new
    @logiciel = Logiciel.new
    _form
  end

  def create
    @logiciel = Logiciel.new(params[:logiciel])
    if @logiciel.save
      flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été crée.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @logiciel = Logiciel.find(params[:id])
    _form
  end

  def update
    @logiciel = Logiciel.find(params[:id])
    if @logiciel.update_attributes(params[:logiciel])
      flash[:notice] = "Le logiciel #{@logiciel.nom} a bien été mis à jour."
      redirect_to :action => 'list'
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    @logiciel = Logiciel.find(params[:id])
    @logiciel.destroy
    flash[:notice] = "Le logiciel #{@logiciel.nom} a bien été supprimé."
    redirect_to :action => 'list'
  end


private
  def _form
    order_by_name = { :order => 'nom' }
    @competences = Competence.find(:all, order_by_name)
    @groupes = Groupe.find(:all, order_by_name)
    @licenses = License.find(:all, order_by_name)
  end  

  def _panel 
    @count = {}
    @clients = Client.find_select if @ingenieur
    @groupes = Groupe.find_select
    @technologies = Competence.find_select
    @groupes = Groupe.find_select

    @count[:paquets] = Paquet.count
    @count[:binaires] = Binaire.count
    @count[:softwares] = Logiciel.count
    @count[:technologies] = Competence.count
  end

end
