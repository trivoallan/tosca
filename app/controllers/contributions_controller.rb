class ContributionsController < ApplicationController

  model :correctif

  def index
    select
    render :action => 'select'
  end

  def list
    return redirect_to :action => 'select' unless params[:id]
    @logiciel = Logiciel.find(params[:id])
    conditions = ["logiciel_id = ?", @logiciel.id]
    #scope_filter do
      @contribution_pages, @contributions = paginate :correctifs, :per_page => 10,
      :order => "created_on DESC", :conditions => conditions
    #end
  end

  def select
    @logiciels = Correctif.find(:all).collect{|c| c.logiciel }.uniq
  end

end

