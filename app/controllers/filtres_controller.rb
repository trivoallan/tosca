#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class FiltresController < ApplicationController

  # sélection des filtres de session
  def index
    @logiciels = Logiciel.find(:all) 
    @groupes = Groupe.find(:all)
    @severites = Severite.find(:all)
    @statuts = Statut.find(:all)
    @types = Typedemande.find(:all)
    Client.with_exclusive_scope do
      @clients = Client.find(:all)
    end    
    @beneficiaires = Beneficiaire.find(:all)
    @ingenieurs = Ingenieur.find(:all)
  end

  # supprime les filtres de session
  def remove_filters
    super
  end

end
