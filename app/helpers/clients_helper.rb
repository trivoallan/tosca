module ClientsHelper

  #Call it : link_to_engagement('Voir','edit', engagement)
  def link_to_engagement(name, action, engagement)
    link_to name, :action => action, :id => engagement.id, :controller => 'engagements'
  end
end
