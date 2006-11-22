module LogicielsHelper
  def link_to_logiciel(l)
    link_to l.nom, :action => 'show', :controller => 'logiciels', :id => l
  end
end
