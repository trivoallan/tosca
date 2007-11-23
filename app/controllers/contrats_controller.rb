#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContratsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contrat_pages, @contrats = paginate :contrats, :per_page => 25
  end

  def show
    @contrat = Contrat.find(params[:id], :include => [:ingenieurs])
  end

  def new
    @contrat = Contrat::Ossa.new
    @contrat.client_id = params[:id]
    _form
  end

public
  def ajax_choose
    render :nothing => true and return unless request.xhr?
    @type = nil
    begin
      klass = Contrat::List[params[:contrat][:class_type].to_i]
      @contrat = klass.new(params[:contrat])
      @type = "contrats/#{klass}/form"
    rescue #if exception, an error message will be set by the rjs file.
    end
  end

  def create
    class_name = "Contrat::#{params[:class_type]}"
    @contrat = Contrat.new(params)
    begin
      @contrat = class_name.constantize.new(params)
    rescue
      _form and render :action => 'new' and return
    end
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
  end
end
