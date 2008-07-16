module VersionsHelper
  
  def link_to_version(version)
    return '-' unless version and version.is_a? Version
    name = version.to_s
    name = "<i>#{name}</i>"
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
