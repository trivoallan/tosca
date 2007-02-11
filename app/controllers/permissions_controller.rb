#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class PermissionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
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
      redirect_to :action => 'list'
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
      redirect_to :action => 'list'
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Permission.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @roles = Role.find_all
  end
end
