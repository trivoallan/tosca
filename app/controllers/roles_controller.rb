#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class RolesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @permissions = Permission.find(:all, :order => 'name', :include => [:roles])
    @roles = Role.find_all
    # @role_pages, @roles = paginate :roles, :per_page => 10
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    _form
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "Le rôle \"#{@role.nom}\" a bien été crée."
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    _form
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = "Le rôle \"#{@role.nom}\" a bien été mis à jour."
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
    # pour update des permissions liées
    if @params[:permission_ids]
      @role.permissions = Permission.find(@params[:permission_ids]) 
    else
      @role.permissions = []
      # @role.errors.add_on_empty('permissions') 
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @permissions = Permission.find(:all, :order => 'name')
  end
end
