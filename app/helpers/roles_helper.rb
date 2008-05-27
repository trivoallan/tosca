module RolesHelper

  # used in account list
  # call it like this :
  # [<%= link_to_edit_role role %>]
  def link_to_edit_role(role)
    return '-' unless role
    link_to role.name, edit_role_path(role)
  end
end
