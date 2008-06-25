module LogicielsHelper

  # Display a link to a Logiciel (software)
  # Options :
  #   * :size => size of the picture,
  #      (:small, :thumb & so on. See app/models/image.rb for full list)
  # Call it like this
  # public_link_to_logiciel @logiciel
  # public_link_to_logiciel @logiciel, :size => :thumb
  def public_link_to_logiciel(logiciel, options = {})
    return '-' unless logiciel and logiciel.is_a? Logiciel
    text = software_logo(logiciel, options)
    options = LinksHelper::NO_HOVER
    text, options = logiciel.name, {} if text.blank?
    public_link_to text, logiciel_path(logiciel), options
  end

  # Link to create a new url for a Logiciel
  def link_to_new_urllogiciel(logiciel_id)
    return '-' unless logiciel_id
    options = new_urllogiciel_path(:logiciel_id => logiciel_id)
    link_to(image_create('an url'), options, LinksHelper::NO_HOVER)
  end

  # Create a link to modify the active value in the form filter
  # Usage :
  #  <%= remote_link_to_software(:all) %> to display all the software
  def remote_link_to_software( param)
    ajax_call = PagesHelper::AJAX_OPTIONS.dup.update(:url => logiciels_path)
    if param == :supported
      text = _('My supported software')
      description = _('Display only software supported by your contract')
      value = 1
    else
      text = _('All software')
      description = _('Display all software')
      value = 0
    end
    js_call = "document.forms['filters'].active.value=#{value};" <<
      remote_function(ajax_call)
    link_to_function(text, js_call, description)
  end

end
