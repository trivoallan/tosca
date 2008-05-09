#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PaquetsController < ApplicationController
  helper :filters, :logiciels, :binaires, :conteneurs, :distributeurs,
    :mainteneurs

  # auto completion in 2 lines, yeah !
  auto_complete_for :paquet, :name

  # TODO : filtres du panel à gauche
  # TODO : faire une interface à base de filtres ?
  # ou  pas d'interfaces du tout.
  def index
    options = { :per_page => 15, :order =>
      'paquets.logiciel_id, paquets.version, paquets.release',
      :include => [:conteneur,:distributeur,:mainteneur,:logiciel] }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    params_paquet = params['paquet']
    conditions = Filters.build_conditions(params_paquet, [
       ['name', 'paquets.name', :like ]
     ]) unless params_paquet.blank?
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
    include =  [ { :logiciel => :groupe }, :distributeur,
                 { :contrat => :client }, :mainteneur, :conteneur ]
    paquet_id = params[:id]
    @paquet = Paquet.find(paquet_id, :include => include)
    cond = [ 'binaires.paquet_id = ? ', paquet_id ]
    options = { :conditions => cond, :include => [:paquet,:socle,:arch] }
    @binaires = Binaire.find(:all, options)
    @changelogs = @paquet.changelogs
  end

  def new
    @paquet = Paquet.new
    _form
    @paquet.mainteneur = Mainteneur.find_by_name('Linagora')
    @paquet.distributeur = Distributeur.find_by_name('(none)')
    @paquet.logiciel_id = params[:logiciel_id]
    @paquet.name = params[:referent]
    @paquet.release = 'lng1'
    @paquet.active = true;
  end

  def create
    @paquet = Paquet.new(params[:paquet])
    if @paquet.save
      flash[:notice] = _('The package %s has been created.') % @paquet.name
      redirect_to logiciel_path(@paquet.logiciel)
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
      flash[:notice] = _('The package %s has been updated.') % @paquet.name
      redirect_to paquet_path(@paquet)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Paquet.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @logiciels = Logiciel.find_select
    @groupes = Groupe.find_select
    @socles = Socle.find_select
    @conteneurs = Conteneur.find_select
    @distributeurs = Distributeur.find_select
    @mainteneurs = Mainteneur.find_select
    @contrats = Contrat.find_select(Contrat::OPTIONS)
  end

  def _panel
    @count = {}
    @clients = Client.find_select(:conditions => 'clients.inactive = 0')
    @count[:paquets] = Paquet.count
    @count[:binaires] = Binaire.count(:include => :paquet)
  end

end
