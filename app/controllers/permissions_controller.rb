#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PermissionsController < ApplicationController
  def index
    @permission_pages, @permissions = paginate :permissions, :order => 'name', :per_page => 100
  end

  def show
    @permission = Permission.find(params[:id])
  end

  def new
    @permission = Permission.new
    _form
  end

  def create
    @permission = Permission.new(params[:permission])
    if @permission.save
      flash[:notice] = 'Permission was successfully created.'
      redirect_to permissions_url
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @permission = Permission.find(params[:id])
    _form
  end

  def update
    @permission = Permission.find(params[:id])
    if @permission.update_attributes(params[:permission])
      flash[:notice] = 'Permission was successfully updated.'
      redirect_to permissions_url
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Permission.find(params[:id]).destroy
    redirect_to permissions_url
  end

  private
  def _form
    @roles = Role.find(:all)
  end
end
