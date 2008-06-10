class AlertsController < ApplicationController
  helper :demandes

  def on_submit
    flash[:contract_ids] = [ 3 ]

    options = { :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = 'demandes.contract_id IN (?) AND demandes.statut_id = 1'
    options[:conditions] = [ conditions, flash[:contract_ids] ]
    @request_found = nil
    Demande.without_include_scope(@ingenieur, @beneficiaire) do
      @request_found = Demande.find(:first, options)
    end

  end

  def ajax_on_submit
    flash[:contract_ids] = flash[:contract_ids]

    options = { :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = 'demandes.contract_id IN (?) AND demandes.statut_id = 1'
    options[:conditions] = [ conditions, flash[:contract_ids]]
    @request_found = Demande.find(:first, options)
    render :partial => 'ajax_on_submit'
  end

end
