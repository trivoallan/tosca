class DemandeSweeper < ActionController::Caching::Sweeper
  # There's a separate sweeper for Comments attached to a request.
  # We can keep them separate, so we do :).
  # But take notes that those 2 others fragements are used :
  #  "#{record.id}/comments"
  #  "#{record.demande_id}/true/requests/front"
  #  "#{record.demande_id}/false/requests/front"

  observe Demande

  # If our sweeper detects that a Request was created call this
  def after_create(record)
    expire_fragment("#{record.id}/true/requests/info")
    expire_fragment("#{record.id}/false/requests/info")
  end

  # If our sweeper detects that a Request was updated call this
  def after_update(record)
    expire_cache_for(record)
  end

  # If our sweeper detects that a Request was deleted call this
  def after_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    # Expire the left panel on a 'comment' action
    expire_fragment("#{record.id}/true/requests/info")
    expire_fragment("#{record.id}/false/requests/info")
  end
end
