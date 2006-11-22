class PiecejointesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @piecejointe_pages, @piecejointes = paginate :piecejointes, :per_page => 10
  end

  def show
    @piecejointe = Piecejointe.find(params[:id])
  end

  def new
    @piecejointe = Piecejointe.new
  end

  def create
    @piecejointe = Piecejointe.new(params[:piecejointe])
    if @piecejointe.save
      flash[:notice] = 'Piecejointe was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @piecejointe = Piecejointe.find(params[:id])
  end

  def update
    @piecejointe = Piecejointe.find(params[:id])
    if @piecejointe.update_attributes(params[:piecejointe])
      flash[:notice] = 'Piecejointe was successfully updated.'
      redirect_to :action => 'show', :id => @piecejointe
    else
      render :action => 'edit'
    end
  end

  def destroy
    Piecejointe.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
