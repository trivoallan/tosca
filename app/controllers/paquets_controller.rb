#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PaquetsController < ApplicationController
  helper :filters, :logiciels, :binaires

  # auto completion in 2 lines, yeah !
  auto_complete_for :paquet, :nom

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  # TODO : filtres du panel à gauche
  # TODO : faire une interface à base de filtres ?
  # ou  pas d'interfaces du tout.
  def list
    options = { :per_page => 15, :order => 
      'paquets.logiciel_id, paquets.version, paquets.release',
      :include => [:conteneur,:distributeur,:mainteneur,:logiciel] }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['paquet', 'nom', 'paquets.nom', :like ] 
     ])
    flash[:conditions] = options[:conditions] = conditions 

    @paquet_pages, @paquets = paginate :paquets, options

    # panel on the left side
    if request.xhr? 
      render :partial => 'paquets_list', :layout => false
    else
      _panel
      @partial_for_summary = 'paquets_info'
    end

  end

  def show
    include =  [ :logiciel, :fournisseur, :distributeur, 
      :contrat, :mainteneur, :conteneur]
    @paquet = Paquet.find(params[:id], :include => include)
    @fichiers = @paquet.fichiers.find(:all, :select => 'fichiers.chemin',
                                      :limit => 10000)
    @changelogs = @paquet.changelogs
  end

  def new
    @paquet = Paquet.new
    _form
    @paquet.mainteneur = Mainteneur.find_by_nom('Linagora')
    @paquet.distributeur = Distributeur.find_by_nom('(none)')
    @paquet.logiciel_id = params[:id]
    @paquet.active = true;
  end

  def create
    @paquet = Paquet.new(params[:paquet])
    if @paquet.save
      flash[:notice] = 'Le paquet '+@paquet.nom+' a bien été crée.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @paquet = Paquet.find(params[:id])
    _form
  end

  def update
    @paquet = Paquet.find(params[:id])
    if @paquet.update_attributes(params[:paquet])
      flash[:notice] = 'Le paquet '+@paquet.nom+' a bien été mis à jour.'
      redirect_to :action => 'list', :id => @paquet
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Paquet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @logiciels = Logiciel.find(:all, :order => 'logiciels.nom')
    @groupes = Groupe.find_select
    @socles = Socle.find_select
    @conteneurs = Conteneur.find_select
    @distributeurs = Distributeur.find_select
    @mainteneurs = Mainteneur.find_select
    @fournisseurs = Fournisseur.find_select
    @contrats = Contrat.find(:all)
  end

  def _panel 
    @count = {}
    @clients = Client.find_select
    @count[:paquets] = Paquet.count
    @count[:binaires] = Binaire.count
  end

end
