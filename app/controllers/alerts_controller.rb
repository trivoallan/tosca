class AlertsController < ApplicationController
  helper :demandes

  def on_submit
    flash[:contrat_ids] = [ 3 ]

    options = { :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = 'demandes.contrat_id IN (?) AND demandes.statut_id = 1'
    options[:conditions] = [ conditions, flash[:contrat_ids] ]
    @request_found = nil
    Demande.without_include_scope(@ingenieur, @beneficiaire) do
      @request_found = Demande.find(:first, options)
    end

  end

  def ajax_on_submit
    flash[:contrat_ids] = flash[:contrat_ids]

    options = { :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = 'demandes.contrat_id IN (?) AND demandes.statut_id = 1'
    options[:conditions] = [ conditions, flash[:contrat_ids]]
    @request_found = Demande.find(:first, options)
    render :partial => 'ajax_on_submit'
  end

end
