module PaquetsHelper
  def link_to_paquet(paquet)
    return "N/A" unless paquet
    nom = paquet.version + " : " + paquet.nom + 
      "  (" + paquet.release + "/" + paquet.arch.nom + "/" + 
      paquet.conteneur.nom + ") ~" + human_size(paquet.taille) 
    link_to nom, :controller => 'paquets', 
    :action => 'show', :id => paquet.id

  end
end
