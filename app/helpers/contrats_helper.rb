module ContratsHelper

  # Cette méthode nécessite un :include => [:client] pour
  # fonctionner correctement
  def link_to_contrat(c)
    return '-' unless c
    link_to c.name, contrat_path(c)
  end

  # call it like :
  # <%= link_to_new_contrat(@client.id) %>
  def link_to_new_contrat(client_id = nil)
    link_to_no_hover(image_create(_('a contract')),
                     new_contrat_path(:client_id => client_id))
  end

  def link_to_new_rule(rule)
    return '' unless rule
    options = self.send("new_#{rule.underscore.tr('/','_')}_path")
    link_to_no_hover image_create(_(rule.humanize)), options
  end

  def link_to_rule(rule)
    return '' unless rule
    options = self.send("#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to_no_hover StaticImage::view, options
  end

  def link_to_edit_rule(rule)
    return '' unless rule
    options = self.send("#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to_no_hover StaticImage::edit, options
  end


end
