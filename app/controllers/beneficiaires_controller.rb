#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BeneficiairesController < ApplicationController
  helper :filters

  def index
    options = { :per_page => 10, :include => [:client,:identifiant] }
    if params['client_id']
      options[:conditions] = ['beneficiaires.client_id=?', params['client_id'] ]
    end
    @clients = Client.find_select
    @beneficiaire_pages, @beneficiaires = paginate :beneficiaires, options

    render :action => 'list'
  end

  def show
    @beneficiaire = Beneficiaire.find(params[:id])
  end

  def new
    case request.method
    when :get
      @beneficiaire = Beneficiaire.new
      _form
    when :post
      @beneficiaire = Beneficiaire.new(params[:beneficiaire])
      if @beneficiaire.save
        flash[:notice] = 'Beneficiaire was successfully created.'
        redirect_to beneficiaires_url
      else
        _form
        render :action => 'new'
      end
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
      redirect_to beneficiaire_url(@beneficiaire)
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    benef = Beneficiaire.find(params[:id])
    identifiant = Identifiant.find(benef.identifiant_id)
    transaction(benef, identifiant) do
      benef.destroy
      identifiant.destroy
    end
    redirect_to beneficiaires_url
  end
private
  def _form
    @clients = Client.find_select
  end

end
