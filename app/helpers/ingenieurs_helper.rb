#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module IngenieursHelper

  def link_to_ingenieurs
    link_to 'Ingénieurs', :action => 'list', :controller => 'ingenieurs'
  end

  def link_to_ingenieur(inge)
    link_to(inge.identifiant.nom, :action => 'show', 
            :controller => 'ingenieurs', :id => inge)
  end
end
