#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BeneficiairesController < ApplicationController
  helper :filters

  def index
    options = { :per_page => 10, :include => [:client,:identifiant] }
    if params.has_key? 'client_id'
      options[:conditions] = ['beneficiaires.client_id=?', params['client_id'] ]
    end
    @clients = Client.find_select
    @beneficiaire_pages, @beneficiaires = paginate :beneficiaires, options
  end

  def show
    @beneficiaire = Beneficiaire.find(params[:id])
  end

  def create
    # should not be called, since the only way to create 
    # user & recipient is from AccountController.
    render :file => :nothing 
  end

  def new
    @beneficiaire = Beneficiaire.new
    _form
  end

  def edit
    @beneficiaire = Beneficiaire.find(params[:id])
    _form
  end

  def update
    @beneficiaire = Beneficiaire.find(params[:id])
    if @beneficiaire.update_attributes(params[:beneficiaire])
      flash[:notice] = _('The recipient was successfully updated.')
      redirect_to beneficiaire_path(@beneficiaire)
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    benef = Beneficiaire.find(params[:id])
    identifiant = Identifiant.find(benef.identifiant_id)
    Identifiant.transaction do
      benef.destroy
      identifiant.destroy
    end
    redirect_to beneficiaires_path
  end
private
  def _form
    @clients = Client.find_select
  end

end
