class DemandeSweeper < ActionController::Caching::Sweeper
  # There's a separate sweeper for Comments attached to a request.
  # We can keep them separate, so we do :).
  observe Demande 

  # If our sweeper detects that a Request was created call this
  def after_create(request)
    expire_fragment("#{record.id}/true/requests/info") 
    expire_fragment("#{record.id}/false/requests/info") 
  end
  
  # If our sweeper detects that a Request was updated call this
  def after_update(request)
    expire_cache_for(request)
  end
  
  # If our sweeper detects that a Request was deleted call this
  def after_destroy(request)
    expire_cache_for(request)
  end
          
  private
  def expire_cache_for(record)
    # Expire the left panel on a 'comment' action
    expire_fragment("#{record.id}/true/requests/info") 
    expire_fragment("#{record.id}/false/requests/info") 
  end
end
