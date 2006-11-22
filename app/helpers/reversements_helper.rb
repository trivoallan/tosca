module ReversementsHelper
  def link_to_reversement(reversement)
    link_to reversement.nom,:controller => 'reversements',
    :action => 'show', :id => reversement.id
  end
end
