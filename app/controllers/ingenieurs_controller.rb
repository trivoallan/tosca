#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class IngenieursController < ApplicationController
  def index
    @competences = Competence.find(:all)
    @ingenieur_pages, @ingenieurs = paginate :ingenieurs, :per_page => 20,
      :include => [:user,:competences]
  end

  def show
    @ingenieur = Ingenieur.find(params[:id],
                                :include => [:user,:competences])
  end

  def new
    @ingenieur = Ingenieur.new
    _form
  end

  def create
    @ingenieur = Ingenieur.new(params[:ingenieur])
    if @ingenieur.save
      flash[:notice] = _('Ingenieur was successfully created.')
      redirect_to ingenieurs_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @ingenieur = Ingenieur.find(params[:id])
    _form
  end

  def update
    @ingenieur = Ingenieur.find(params[:id])
    if @ingenieur.update_attributes(params[:ingenieur])
      flash[:notice] = _('Ingenieur was successfully updated.')
      redirect_to ingenieurs_path
    else
      _form and render :action => 'edit'
    end

  end

  # TODO : mettre dans le modèle, avec un before_destroy
  def destroy
    inge = Ingenieur.find(params[:id])
    user = User.find(inge.user_id)
    User.transaction do
      inge.destroy
      user.destroy
    end
    redirect_to ingenieurs_path
  end

  private
  def _form
    @competences = Competence.find(:all)
  end
end
