#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contrat_pages, @contrats = paginate :contrats, :per_page => 10,
    :include => [:client]
  end

  def show
    @contrat = Contrat.find(params[:id], :include => [:ingenieurs])
  end

  def new
    @contrat = Contrat.new
    @contrat.client_id = params[:id]
    @contrat[:type] = ''
    _form
  end

private
    PREFIX_PARTIAL_INFORMATIONS = 'informations_'

public
  def ajax_display_attribut_contract
    @type = PREFIX_PARTIAL_INFORMATIONS
    case params[:contrat][:type]
    when Contrat::OSSA
      @type << "ossa"
    when Contrat::SUPPORT
      @type << "support"
    end
  end

  def create
    @contrat = Contrat.new(params[:contrat])
    #Type is not a visible attribute of contrat
    @contrat[:type] = params[:contrat][:type]
    if @contrat.save
      team = params[:team]
      if team and team[:ossa] == '1'
        @contrat.ingenieurs.concat(Ingenieur.find_ossa(:all))
        @contrat.save
      end
      flash[:notice] = _('Contract was successfully created.')
      redirect_to contrats_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contrat = Contrat.find(params[:id])
    _form
  end

  def update
    @contrat = Contrat.find(params[:id])
    if @contrat.update_attributes(params[:contrat])
      team = params[:team]
      if team and team[:ossa] == '1'
        @contrat.ingenieurs.concat(Ingenieur.find_ossa(:all))
        @contrat.save
      end
      flash[:notice] = _('Contrat was successfully updated.')
      redirect_to contrat_path(@contrat)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contrat.find(params[:id]).destroy
    redirect_to contrats_path
  end

private
  def _form
    # Needed in order to be able to assiocate with it
    Client.with_exclusive_scope do
      @clients = Client.find_select
    end
    @engagements = Engagement.find(:all, Engagement::OPTIONS)
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
  end
end
