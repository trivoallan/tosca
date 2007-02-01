module TachesHelper

  def link_to_tache(tache)
    return "N/A" unless tache
    link_to tache.resume, :controller => 'taches', 
    :action => 'show', :id => tache.id
  end

end
