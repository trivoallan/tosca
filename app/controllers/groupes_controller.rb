#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class GroupesController < ApplicationController
  # public access to the list
  skip_before_filter :login_required
  before_filter :login_required, :except => [:index,:show]

  helper :logiciels

  def index
    @groupe_pages, @groupes = paginate :groupes, :per_page => 20,
    :order => 'groupes.nom'
  end

  def show
    @groupe = Groupe.find(params[:id])
  end

  def new
    @groupe = Groupe.new
  end

  def create
    @groupe = Groupe.new(params[:groupe])
    if @groupe.save
      flash[:notice] = 'Groupe was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @groupe = Groupe.find(params[:id])
  end

  def update
    @groupe = Groupe.find(params[:id])
    if @groupe.update_attributes(params[:groupe])
      flash[:notice] = 'Groupe was successfully updated.'
      redirect_to :action => 'show', :id => @groupe
    else
      render :action => 'edit'
    end
  end

  def destroy
    Groupe.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
