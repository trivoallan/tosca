#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ClassificationsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @classification_pages, @classifications = paginate :classifications, 
    :per_page => 10, :include => [:logiciel,:client,:groupe,:bouquet]
  end

  def show
    @classification = Classification.find(params[:id])
  end

  def new
    @classification = Classification.new
    _form
  end

  def create
    @classification = Classification.new(params[:classification])
    if @classification.save
      flash[:notice] = 'Classification was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @classification = Classification.find(params[:id])
    _form
  end

  def update
    @classification = Classification.find(params[:id])
    if @classification.update_attributes(params[:classification])
      flash[:notice] = 'Classification was successfully updated.'
      redirect_to :action => 'show', :id => @classification
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Classification.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  private
  def _form
    @logiciels = Logiciel.find_all
    @groupes = Groupe.find_all
    @bouquets = Bouquet.find_all
    @socles = Socle.find_all
  end
end
