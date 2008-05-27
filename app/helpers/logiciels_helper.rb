module LogicielsHelper

  # Display a link to a Logiciel (software)
  def public_link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    text = software_logo(logiciel)
    text = logiciel.name if text.blank?
    public_link_to text, logiciel_path(logiciel), LinksHelper::NO_HOVER
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
  def remote_link_to_software( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => logiciels_path)
    if param == :supported
      text = _('My supported softwares')
      description = _('Display only software supported by your contract')
      value = 1
    else
      text = _('All softwares')
      description = _('Display all softwares')
      value = 0
    end
    js_call = "document.forms['filters'].active.value=#{value};" <<
      remote_function(ajax_call)
    link_to_function(text, js_call, description)
  end

end
