class AlertsController < ApplicationController
  helper :demandes

  def index
    @teams = Team.find_select
  end
  
  def on_submit
    flash[:team_ids] = params[:team_ids]
    new_request
  end

  def ajax_on_submit
    flash[:team_ids] = flash[:team_ids]
    new_request
    render :partial => 'ajax_on_submit'
  end

  private
  def new_request
    conditions = [ 'demandes.contract_id IN (?) AND demandes.statut_id = 1', flash[:team_ids]]
    @requests_found = Demande.find(:all, :conditions => conditions)
  end
  
end
