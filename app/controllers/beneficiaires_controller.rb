#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BeneficiairesController < ApplicationController
  helper :filters

  def index
    list and render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def list
    @clients = Client.find_select
    @beneficiaire_pages, @beneficiaires = paginate :beneficiaires, 
    :per_page => 10, :include => [:client,:identifiant]
  end

  def show
    @beneficiaire = Beneficiaire.find(params[:id])
  end

  def new
    @beneficiaire = Beneficiaire.new
    _form
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
    _form
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

private
  def _form
    @identifiants = Identifiant.find :all
    @clients = Client.find :all
    @responsables = Beneficiaire.find :all
  end  
end
