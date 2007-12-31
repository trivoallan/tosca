#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contrat_pages, @contrats = paginate :contrats, :per_page => 25
  end

  def show
    @contrat = Contrat.find(params[:id])
  end

  def new
    # It is the default contract
    @contrat = Contrat.new
    @contrat.client_id = params[:id]
    @contrat.rule_type = 'Ossa'
    _form
  end

public
  def ajax_choose
    render :nothing => true and return unless request.xhr?
    @rules = nil
    if params.has_key? 'TimeTicket'
      @rules = TimeTicket.find(:all)
    end
    if params[:value] == 'Ossa'
      @rules = Ossa.find(:all)
    end
    @type = 'rules' if @rules
  end

  def create
    @contrat = Contrat.new(params[:contrat])
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
    # Needed in order to be able to auto-associate with it
    Client.with_exclusive_scope do
      @clients = Client.find_select
    end
    @engagements = Engagement.find(:all, Engagement::OPTIONS)
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @rules = []
    begin
      @rules = @contrat.rule_type.constantize.find(:all)
    rescue
      flash[:warn] = _('Unknown rules for this contract.')
    end
  end
end
