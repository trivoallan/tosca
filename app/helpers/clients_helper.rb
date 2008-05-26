#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClientsHelper

  def link_to_client(c)
    return '-' unless c
    link_to c.name, client_path(c)
  end

  # lien vers mon offre / mon client
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(image = false)
    return nil unless @beneficiaire
    label = image ? logo_client(@beneficiaire.client) : _('My&nbsp;Offer')
    link_to label, client_path(@beneficiaire.client_id)
  end


  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_clients(:all) %> to display all the softwares
  def remote_link_to_clients( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => clients_path)
    if param == :actives
      text = _('Active clients')
      description = _('Display only active clients')
      value = 1
    else # :all
      text = _('Inactive clients')
      description = _('Display only inactive clients')
      value = -1
    end
    js_call = "document.forms['filters'].elements['filters[active]'].value=#{value};" <<
      remote_function(ajax_call)
    link_to_function(text, js_call, description)
  end

end
