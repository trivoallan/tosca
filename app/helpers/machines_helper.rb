module MachinesHelper

  # call it like :
  # <%= link_to_machine @machine %>
  def link_to_machine(c)
    return "-" unless c
    link_to c.to_s, machine_path(c)
  end


end
