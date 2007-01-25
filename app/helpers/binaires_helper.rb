#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return 'N/A' unless binaire and binaire.paquet
    nom = "#{binaire.nom}-#{binaire.paquet.version}-#{binaire.paquet.release}"
    link_to nom, :controller => 'binaires', :action => 'show', :id => binaire.id
  end

  
end
