#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class MachinesController < ApplicationController
  helper :socles
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @machine_pages, @machines = paginate :machines, :per_page => 250,
    :include => [:socle,:hote], :order => 'machines.hote_id, machines.acces'
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def new
    @machine = Machine.new
    _form
  end

  def create
    @machine = Machine.new(params[:machine])
    if @machine.save
      flash[:notice] = 'Machine was successfully created.'
      redirect_to :action => 'list'
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @machine = Machine.find(params[:id])
    _form
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update_attributes(params[:machine])
      flash[:notice] = 'Machine was successfully updated.'
      redirect_to :action => 'list', :id => @machine
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Machine.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  def _form
    @socles = Socle.find(:all, :select => 'socles.nom, socles.id', 
                         :order => 'socles.nom')
    conditions = ['machines.virtuelle = ?', 0] 
    @hotes = Machine.find(:all, :select => 'machines.acces, machines.id',
                          :conditions => conditions)
  end
end
