#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class TypecontributionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @typecontribution_pages, @typecontributions = paginate :typecontributions, :per_page => 10
  end

  def show
    @typecontribution = Typecontribution.find(params[:id])
  end

  def new
    @typecontribution = Typecontribution.new
  end

  def create
    @typecontribution = Typecontribution.new(params[:typecontribution])
    if @typecontribution.save
      flash[:notice] = 'Typecontribution was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @typecontribution = Typecontribution.find(params[:id])
  end

  def update
    @typecontribution = Typecontribution.find(params[:id])
    if @typecontribution.update_attributes(params[:typecontribution])
      flash[:notice] = 'Typecontribution was successfully updated.'
      redirect_to :action => 'show', :id => @typecontribution
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typecontribution.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
