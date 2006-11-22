#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class MachinesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @machine_pages, @machines = paginate :machines, :per_page => 10
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def new
    @machine = Machine.new
    @socles = Socle.find_all
  end

  def create
    @machine = Machine.new(params[:machine])
    if @machine.save
      flash[:notice] = 'Machine was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @machine = Machine.find(params[:id])
    @socles = Socle.find_all
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update_attributes(params[:machine])
      flash[:notice] = 'Machine was successfully updated.'
      redirect_to :action => 'show', :id => @machine
    else
      render :action => 'edit'
    end
  end

  def destroy
    Machine.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
