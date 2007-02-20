#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LogicielsController < ApplicationController
  helper :paquets, :demandes, :competences, :classifications
  
  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

  before_filter :verifie, :only => 
    [ :show, :edit, :update, :destroy ]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def verifie
    super(Logiciel)
  end

  def index
    list
    render :action => 'list'
  end

  def content_columns
    @content_columns ||= columns.reject { |c| 
      c.primary || c.name =~ /(_id|_count|Description)$/  
    }
  end

  # affiche la liste des logiciels avec filtres
  def list
    @filter = params[:filter]
    @search = params[:logiciel]
    @groupe = params[:groupe_id] if params[:groupe_id] != ''
    $orderway = ($orderway == nil || $orderway == " ASC") ? " DESC" : " ASC"
    @order += $orderway if @order != nil 

    clogiciel = [ " logiciels.nom LIKE ?", "%" + @search[0] + "%" ] if @search != nil
    cclassification_groupe = ['classifications.groupe_id = ? ', @groupe ] if @groupe != nil  
    #options = compute_scope([:classifications], clogiciel, cclassification_groupe)[:find] ||= {}
    options = compute_scope(nil, clogiciel)[:find] ||= {}
    options = options.update(:per_page => 15, :order => 'logiciels.nom')

    @count = {}
    @clients = Client.find_select
    @groupes = Groupe.find_select
    @technologies = Competence.find_select

    @groupes = Classification.find(:all).collect{|c| c.groupe}.uniq
    #scope_filter do
    @count[:paquets] = Paquet.count
    @count[:binaires] = Binaire.count
    @count[:softwares] = Logiciel.count
    @count[:technologies] = Competence.count

      @logiciel_pages, @logiciels = paginate :logiciels, options
    #end
  end

  def rpmlist
    @logiciels = Logiciel.find(:all)
  end

  def show
    @logiciel = Logiciel.find(params[:id])
    if @beneficiaire
      @demandes = @beneficiaire.demandes.find_all_by_logiciel_id(params[:id])
    else
      @demandes = Demande.find_all_by_logiciel_id(params[:id])
    end
  end

  def new
    @logiciel = Logiciel.new
    @competences = Competence.find(:all, :order => "nom")
    @classifications = Classification.find_all
    @licenses = License.find_all
  end

  def create
    @logiciel = Logiciel.new(params[:logiciel])

    if @params[:competence_ids]
      @logiciel.competences = Competence.find(@params[:competence_ids]) 
    else
      @logiciel.competences = []
      @logiciel.errors.add_on_empty('competences') 
      render :action => 'edit'
      return 
    end

    if @logiciel.save
      flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été crée.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @logiciel = Logiciel.find(params[:id])
    @competences = Competence.find(:all, :order => "nom")
    @classifications = Classification.find(:all, :order => "client_id, bouquet_id, groupe_id")
    @licenses = License.find(:all, :order => "nom")
  end

  def update
    @logiciel = Logiciel.find(params[:id])
    @licenses = License.find_all
    @competences = Competence.find_all

    if @params[:competence_ids]
      @logiciel.competences = Competence.find(@params[:competence_ids]) 
    else
      @logiciel.competences = []
      @logiciel.errors.add_on_empty('competences') 
      render :action => 'edit'
      return 
    end

    if @logiciel.update_attributes(params[:logiciel])
      flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été mis à jour.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @logiciel = Logiciel.find(params[:id])
    @logiciel.destroy
    flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été supprimé.'
    redirect_to :action => 'list'
  end

  private

end
