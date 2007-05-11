#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module GroupesHelper

  @@groupes = nil
  def public_link_to_groupes
    @@groupes ||= public_link_to(_('classifications'),
        :controller => 'groupes', :action => 'list')
  end

end
