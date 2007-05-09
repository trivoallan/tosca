class NewsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @new_pages, @news = paginate :news, :per_page => 10
  end

  def show
    @new = New.find(params[:id])
  end

  def new
    @new = New.new
  end

  def create
    @new = New.new(params[:new])
    if @new.save
      flash[:notice] = 'New was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @new = New.find(params[:id])
  end

  def update
    @new = New.find(params[:id])
    if @new.update_attributes(params[:new])
      flash[:notice] = 'New was successfully updated.'
      redirect_to :action => 'show', :id => @new
    else
      render :action => 'edit'
    end
  end

  def destroy
    New.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
