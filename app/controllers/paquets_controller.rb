#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PaquetsController < ApplicationController
  helper :logiciels, :binaires


  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @filter = @params['filter']
    @order = @params['order']
    @search = @params['paquet']
    @action = 'list'
#    case @order
#      when /ASC$/; @order["ASC"] = "DESC"
#      when /DESC$/; @order["DESC"] = "ASC"
#      when /^a-z*$/; @order += " ASC"
#      else; 
#    end
    if @filter != nil
      @conditions = @filter.split(',')
      @conditions[0] += " = ?"
    end

    conditions = nil
    # @count = Paquet.count
    if @search != nil
      conditions = [ " nom LIKE ?", "%" + @search[0] + "%" ]
    end

    @count = Paquet.count
    @paquet_pages, @paquets = paginate :paquets, :per_page => 25, 
      :order => @order, :conditions => conditions, :include =>
      [:conteneur,:distributeur,:mainteneur,:logiciel]
  end

  def show
    include =  [ :logiciel, :fournisseur, :distributeur, 
      :contrat, :mainteneur, :conteneur]
    @paquet = Paquet.find(params[:id], :include => include)
    @fichiers = @paquet.fichiers.find(:all, :select => 'fichiers.chemin')
    @changelogs = @paquet.changelogs
    # Fichier.find_all_by_paquet_id(params[:id], :limit => 1000)
  end



  def new
    @paquet = Paquet.new
    _form
    @paquet.mainteneur = Mainteneur.find_by_nom('Linagora')
    @paquet.distributeur = Distributeur.find_by_nom('(none)')
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
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Paquet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  
  def scope_beneficiaire
    if @beneficiaire
      ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
      Paquet.with_scope({ :find => { :conditions => 
                              [ "contrat_id IN (#{ids})" ]
                          }
                        }) { yield }
    else
      yield
    end
  end

  def _form
    @logiciels = Logiciel.find(:all, :order => 'nom')
    @groupes = Groupe.find_all
    @bouquets = Bouquet.find_all
    @socles = Socle.find_all
    @conteneurs = Conteneur.find_all
    @distributeurs = Distributeur.find_all
    @mainteneurs = Mainteneur.find_all
    @fournisseurs = Fournisseur.find_all
    @contrats = Contrat.find_all
  end

end
