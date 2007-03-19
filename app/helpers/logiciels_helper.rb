#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module LogicielsHelper
  def link_to_logiciel(l)
    return '-' unless l
    link_to l.nom, :action => 'show', :controller => 'logiciels', :id => l
  end
end
