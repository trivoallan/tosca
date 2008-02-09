module KnowledgesHelper

  # Call it like this :
  # <%= link_to_knowledge(@knowledge) %>
  def link_to_knowledge(k)
    return '-' unless k and k.is_a? Knowledge
    name = "#{k.level} - #{k.name}"
    link_to name, knowledge_path(k)
  end

end
