#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module LogicielsHelper

  # Display a link to a Logiciel (software)
  def public_link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    public_link_to logiciel.nom, logiciel_path(logiciel)
  end

  # Link to create a new url for a Logiciel
  def link_to_new_urllogiciel(logiciel_id)
    return '-' unless logiciel_id
    options = new_urllogiciel_path(:logiciel_id => logiciel_id)
    link_to(image_create('an url'), options, LinksHelper::NO_HOVER)
  end

  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_software(:all) %> to display all the softwares
  #TODO pas DRY : dans demandes_helpers il y a la même chose
  #     mais le AJAX_CALL est différent
    AJAX_CALL = PagesHelper::AJAX_OPTIONS.dup.update(
      :url => '../logiciels/list')
  def remote_link_to_software( param)
    if param == :supported
      text = _('My supported softwares')
      description= _('Display only software supported by your contract')
      value = 1
    else
      text = _('All softwares')
      description= _('Display all softwares')
      value = 0
    end
    js_call = "document.forms['filters'].active.value=" << value.to_s << ";
      #{remote_function(AJAX_CALL)}"
    link_to_function(text, js_call, description)
  end


end
