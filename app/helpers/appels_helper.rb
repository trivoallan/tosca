module AppelsHelper

  # call it like : link_to_call call
  def link_to_call(appel)
    link_to StaticImage::view, appel_url(:id => appel.id)
  end

  # call it like : link_to_add_call demande.id
  def link_to_add_call(demande_id)
    return '-' unless demande_id
    link_to 'Ajouter un appel', new_appel_url(:id => demande_id)
  end
end
