#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContratsHelper

  # Cette méthode nécessite un :include => [:client] pour
  # fonctionner correctement
  def link_to_contrat(c)
    return '-' unless c
    link_to c.name, contrat_path(c)
  end

  # call it like :
  # <%= link_to_new_contribution(@client.id) %>
  def link_to_new_contrat(client_id = nil)
    link_to(image_create(_('a contract')),
            new_contrat_path(:client_id => client_id),
            LinksHelper::NO_HOVER)
  end

  def link_to_new_rule(rule)
    return '' unless rule
    options = self.send("new_#{rule.underscore.tr('/','_')}_path")
    link_to(image_create(_(rule.humanize)), options, LinksHelper::NO_HOVER)
  end

  def link_to_rule(rule)
    return '' unless rule
    options = self.send("#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to(StaticImage::view, options,  LinksHelper::NO_HOVER)
  end

  def link_to_edit_rule(rule)
    return '' unless rule
    options = self.send("#{ActionController::RecordIdentifier.singular_class_name(rule)}_path", rule)
    link_to(StaticImage::edit, options,  LinksHelper::NO_HOVER)
  end


end
