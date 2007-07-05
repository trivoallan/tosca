#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module LogicielsHelper

  # Display a link to a Logiciel (software)
  def link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    link_to logiciel.nom, :action => 'show', :controller => 'logiciels', 
      :id => logiciel
  end

  # Display a link to a Logiciel (software)
  def public_link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    public_link_to logiciel.nom, :action => 'show', :controller => 'logiciels', 
      :id => logiciel
  end


  @@logiciels = nil
  def public_link_to_logiciels()
    @@logiciels ||= public_link_to(_('logiciels'), 
        :action => 'list', :controller => 'logiciels')
  end

  def public_link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    public_link_to logiciel.nom, :action => 'show', :controller => 'logiciels', :id => logiciel
  end

  # Link to create a new url for a Logiciel
  def link_to_new_urllogiciel(logiciel_id)
    return '-' unless logiciel_id 
    options = { :controller => 'urllogiciels', :action => 'new', :logiciel_id => logiciel_id }
    link_to(image_create('une url'), options, LinksHelper::NO_HOVER)
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
      text = _('Mes Logiciels')
      description= _('Affiche uniquement les logiciels avec lesquels vous avez un contrat')
      value = 1
    else
      text= _('Tous les logiciels')
      description= _('Affiche tous les logiciels')
      value = 0
    end
    js_call = "document.forms['filters'].active.value=" << value.to_s << "; 
      #{remote_function(AJAX_CALL)}"
    link_to_function(text, js_call, description)
  end
  

end
