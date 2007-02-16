#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BeneficiairesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }


  def list
    @clients = Client.find(:all)
    scope_filter do 
      @beneficiaire_pages, @beneficiaires = 
        paginate :beneficiaires, :per_page => 10, 
      :select => 'beneficiaires.id, identifiants.nom as identifiants_nom, '+
        'clients.id as client_id, clients.nom as client_nom, ' + 
        'beneficiaires.domaine',
      :joins => 'INNER JOIN clients ON clients.id=beneficiaires.client_id '+
        'INNER JOIN identifiants ON identifiants.id=beneficiaires.identifiant_id'
      # :include => [:client,:identifiant]
    end
  end

  def show
    @beneficiaire = Beneficiaire.find(params[:id])
  end

  def new
    @beneficiaire = Beneficiaire.new
    @identifiants = Identifiant.find_all
    @clients = Client.find_all
    @responsables = Beneficiaire.find_all
  end

  def create
    @beneficiaire = Beneficiaire.new(params[:beneficiaire])
    if @beneficiaire.save
      flash[:notice] = 'Beneficiaire was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @beneficiaire = Beneficiaire.find(params[:id])
    @identifiants = Identifiant.find_all
    @clients = Client.find_all
    @responsables = Beneficiaire.find_all
  end

  def update
    @beneficiaire = Beneficiaire.find(params[:id])
    if @beneficiaire.update_attributes(params[:beneficiaire])
      flash[:notice] = 'Beneficiaire was successfully updated.'
      redirect_to :action => 'show', :id => @beneficiaire
    else
      render :action => 'edit'
    end
  end

  def destroy
    benef = Beneficiaire.find(params[:id])
    identifiant = Identifiant.find(benef.identifiant_id)
    benef.destroy
    identifiant.destroy
    redirect_to :action => 'list'
  end
end
