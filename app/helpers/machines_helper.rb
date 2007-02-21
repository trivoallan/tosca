#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module MachinesHelper

  # call it like : 
  # <%= link_to_machine @machine %>
  def link_to_machine(c)
    return "N/A" unless c
    link_to c.to_s, :controller => 'machines', 
    :action => 'show', :id => c
  end


end
