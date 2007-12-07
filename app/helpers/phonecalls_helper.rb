module PhonecallsHelper

  # call it like : link_to_call call
  def link_to_call(phonecall)
    link_to StaticImage::view, phonecall_url(:id => phonecall.id)
  end

  # call it like : link_to_add_call demande.id
  def link_to_add_call(demande_id)
    return '-' unless demande_id
    link_to _('Add a phone call'), new_phonecall_url(:id => demande_id)
  end
end
