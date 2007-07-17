#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class UrllogicielsController < ApplicationController
  helper :logiciels

  def index
    @urllogiciel_pages, @urllogiciels = paginate :urllogiciels,
     :per_page => 10, :include => [:logiciel,:typeurl],
     :order => 'urllogiciels.logiciel_id'
  end

  def show
    @urllogiciel = Urllogiciel.find(params[:id])
  end

  def new
    @urllogiciel = Urllogiciel.new
    _form
  end

  def create
    @urllogiciel = Urllogiciel.new(params[:urllogiciel])
    if @urllogiciel.save
      flash[:notice] = _('The url of "%s" has been created successfully.') %
        @urllogiciel.valeur
      redirect_to logiciel_path(@urllogiciel.logiciel)
    else
      render :action => 'new'
    end
  end

  def edit
    @urllogiciel = Urllogiciel.find(params[:id])
    _form
  end

  def update
    @urllogiciel = Urllogiciel.find(params[:id])
    if @urllogiciel.update_attributes(params[:urllogiciel])
      flash[:notice] = 'Urll mis à jour correctement.'
      redirect_to :controller => 'logiciels' , :action => 'show', :id =>
        @urllogiciel.logiciel
    else
      render :action => 'edit'
    end
  end

  def destroy
    Urllogiciel.find(params[:id]).destroy
    redirect_to urllogiciels_path
  end

private
  def _form
    @typeurls = Typeurl.find_select
    @logiciels = Logiciel.find_select
  end
end
