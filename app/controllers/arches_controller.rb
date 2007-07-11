#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ArchesController < ApplicationController
  def index
    @arch_pages, @arches = paginate :arches, :per_page => 10
  end

  def show
    @arch = Arch.find(params[:id])
  end

  def create
    @arch = Arch.new(params[:arch])
    if @arch.save
      flash[:notice] = 'Arch was successfully created.'
      redirect_to arches_url
    else
      render :action => 'new'
    end
  end

  def new
    @arch = Arch.new
  end

  def edit
    @arch = Arch.find(params[:id])
  end

  def update
    @arch = Arch.find(params[:id])
    if @arch.update_attributes(params[:arch])
      flash[:notice] = 'Arch was successfully updated.'
      redirect_to arch_url(@arch)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Arch.find(params[:id]).destroy
    redirect_to arches_url
  end
end
