module ProjetsHelper

  def link_to_projet(projet)
    return "N/A" unless projet
    link_to projet.resume, :controller => 'projets', 
    :action => 'show', :id => projet
  end

end
