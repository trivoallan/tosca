#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class FiltresController < ApplicationController

  # sélection des filtres de session
  def index
    @logiciels = Logiciel.find_select 
    @groupes = Groupe.find_select
    @severites = Severite.find_select
    @statuts = Statut.find_select
    @types = Typedemande.find_select
    Client.with_exclusive_scope do
      @clients = Client.find_select
    end    
    @beneficiaires = Beneficiaire.find_select(:all, :include => Beneficiaire::INCLUDE)
    @ingenieurs = Ingenieur.find_select(:all, :include => Ingenieur::INCLUDE)
  end

  # supprime les filtres de session
  def remove_filters
    super
  end

end
