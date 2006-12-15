#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module IngenieursHelper

  def link_to_ingenieurs
    link_to 'Ingénieurs', :action => 'list', :controller => 'ingenieurs'
  end
end
