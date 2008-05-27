module GroupesHelper

  @@groupes = nil
  def public_link_to_groupes
    @@groupes ||= public_link_to(_('classification'), groupes_url)
  end

  # Lien vers la consultation d'UN groupe
  def link_to_groupe(groupe)
      link_to groupe.name, groupe_url(:id => groupe.id)
  end


end
