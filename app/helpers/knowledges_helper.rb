module KnowledgesHelper

  # Call it like this :
  # <%= link_to_knowledge(@knowledge) %>
  def link_to_knowledge(k)
    return '-' unless k and k.is_a? Knowledge
    name = "#{k.level} - #{k.name}"
    link_to name, knowledge_path(k)
  end

  def link_to_new_knowledge
    return '' if @user_engineer && @user_engineer.user_id != session[:user].id
    options = new_knowledge_path
    link_to(image_create('a knowledge'), options, LinksHelper::NO_HOVER)
  end

end
