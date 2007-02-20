#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ClassificationsHelper

  # optimize again and again 
  # compute_once, call it everywhere ;)
  @@list = nil
  def link_to_group_list
    @@list ||= link_to 'Classification', :controller => 
      'groupes', :action => 'list'
  end
end
