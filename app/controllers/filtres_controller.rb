#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class FiltresController < ApplicationController

  # sélection des filtres de session
  def index
    @logiciels = Logiciel.find_select(:all) 
    @groupes = Groupe.find_select(:all)
    @severites = Severite.find_select(:all)
    @statuts = Statut.find_select(:all)
    @types = Typedemande.find_select(:all)
    Client.with_exclusive_scope do
      @clients = Client.find_select(:all)
    end    
    @beneficiaires = Beneficiaire.find_select(:all, :include => Beneficiaire::INCLUDE)
    @ingenieurs = Ingenieur.find_select(:all, :include => Ingenieur::INCLUDE)
  end

  # supprime les filtres de session
  def remove_filters
    super
  end

end
