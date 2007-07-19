#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module IngenieursHelper

  def link_to_ingenieurs
    link_to 'Ingénieurs', ingenieurs_path
  end

  def link_to_ingenieur(inge)
    link_to(inge.identifiant.nom, ingenieur_path(inge))
  end
end
