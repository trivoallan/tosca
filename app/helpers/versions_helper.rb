module VersionsHelper
  # Il faut mettre un :include => [:arch,:conteneur] pour accélérer l'affichage
  def link_to_version(version)
    return '-' unless version and version.is_a? Paquet
    name = version.to_s
    name = "<i>#{name}</i>" unless version.active
    link_to name, version_path(version)
  end

  # call it like :
  # <%= link_to_new_version(@logiciel) %>
  def link_to_new_version(logiciel = nil)
    return '' unless logiciel
    path = new_version_path(:logiciel_id => logiciel.id,:referent => logiciel.referent)
    link_to_no_hover(image_create(_('a package')), path)
  end

end
