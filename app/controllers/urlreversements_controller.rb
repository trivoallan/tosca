#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class UrlreversementsController < ApplicationController
  helper :logiciels

  def index
    @urlreversement_pages, @urlreversements = paginate :urlreversements,
    :per_page => 10
  end

  def show
    @urlreversement = Urlreversement.find(params[:id])
  end

  def new
    @urlreversement = Urlreversement.new
    _form
  end

  def create
    @urlreversement = Urlreversement.new(params[:urlreversement])
    if @urlreversement.save
      flash[:notice] = _('Urlreversement was successfully created.')
      redirect_to contribution_path(@urlreversement.contribution_id)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urlreversement = Urlreversement.find(params[:id])
    _form
  end

  def update
    @urlreversement = Urlreversement.find(params[:id])
    if @urlreversement.update_attributes(params[:urlreversement])
      flash[:notice] = _('Urlreversement was successfully updated.')
      redirect_to contribution_path(@urlreversement.contribution_id)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    url = Urlreversement.find(params[:id])
    if @session[:user].role_id != 1 and # admin_role
        urlreversement.contribution.ingenieur_id != @ingenieur.id
      flash[:warn] = _('You are not the author of this one.')
      redirect_to contribution_path(url.contribution) and return
    end
    url.destroy
    redirect_to contributions_path
  end

private
  def _form
    @contributions = Contribution.find(:all)
    if params[:contribution_id]
      @urlreversement.contribution_id = params[:contribution_id].to_i
    end
  end
end
