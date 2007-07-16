#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class SupportsController < ApplicationController
  def index
    @support_pages, @supports = paginate :supports, :per_page => 10
  end

  def show
    @support = Support.find(params[:id])
  end

  def new
    @support = Support.new
  end

  def create
    @support = Support.new(params[:support])
    if @support.save
      flash[:notice] = 'Support was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @support = Support.find(params[:id])
  end

  def update
    @support = Support.find(params[:id])
    if @support.update_attributes(params[:support])
      flash[:notice] = 'Support was successfully updated.'
      redirect_to :action => 'show', :id => @support
    else
      render :action => 'edit'
    end
  end

  def destroy
    Support.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
