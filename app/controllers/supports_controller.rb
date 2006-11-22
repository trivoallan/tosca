class SupportsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
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
      redirect_to :action => 'list'
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
    redirect_to :action => 'list'
  end
end
