#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return '-' unless binaire and binaire.paquet
    link_to binaire.to_s, binaire_path(binaire.id)
  end

  # Link to create a new url for a Logiciel
  def link_to_new_binaire(paquet_id)
    return '-' if paquet_id.blank?
    options = new_binaire_path(:paquet_id => paquet_id)
    link_to_no_hover image_create(_('binary')), options
  end

  def link_to_update_binary_files(binaire_id)
    return '-' if binaire_id.blank?
    link_to(_("Update files of this binary package"),
            update_files_binaire_path(:id => binaire_id), :method => :post)
  end
end
