#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController

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
    @logiciels = Contribution.find(:all, :order => 'reverse_le').collect{|c| c.logiciel }.uniq
  end

end

