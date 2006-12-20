#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class InteractionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @interaction_pages, @interactions = paginate :interactions, 
    :per_page => 10, :include => [:logiciel]
  end

  def show
    @interaction = Interaction.find(params[:id])
  end

  def new
    @interaction = Interaction.new
    _form
  end

  def create
    @interaction = Interaction.new(params[:interaction])
    if @interaction.save
      flash[:notice] = 'Interaction was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @interaction = Interaction.find(params[:id])
    _form
  end

  def update
    @interaction = Interaction.find(params[:id])
    if @interaction.update_attributes(params[:interaction])
      flash[:notice] = 'Interaction was successfully updated.'
      redirect_to :action => 'show', :id => @interaction
    else
      render :action => 'edit'
    end
  end

  def destroy
    Interaction.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @ingenieurs = Ingenieur.find_all
    @logiciels = Logiciel.find_all
  end

end
