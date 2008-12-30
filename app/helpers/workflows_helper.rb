module WorkflowsHelper

  # call it like :
  # <%= link_to_new_workflow(@software) %>
  def link_to_new_workflow(issuetype_id)
    return '' unless issuetype_id
    path = new_workflow_path(:issuetype_id => issuetype_id)
    link_to(image_create(_('a new flow')), path)
  end

end
