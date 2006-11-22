#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return "N/A" unless binaire and File.exist?(binaire.fichier)
    nom = binaire.fichier[/[._ \-a-zA-Z0-9]*$/] 
    link_to "Télécharger #{nom}", 
    url_for_file_column(binaire, "fichier", :absolute => true)
  end

  
end
