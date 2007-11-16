#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return '-' unless binaire and binaire.paquet
    name = "#{binaire.name}-#{binaire.paquet.version}-#{binaire.paquet.release}"
    link_to name, binaire_path(binaire.id)
  end

end
