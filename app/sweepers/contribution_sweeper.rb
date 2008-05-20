class ContributionSweeper < ActionController::Caching::Sweeper
  # Currently used to maintain cache correctly for request & comments
  observe Contribution

  # If sweeper detects that a Request was created or updated
  def after_save(record)
    expire_cache_for(record)
  end

  # If sweeper detects that a Request was deleted call this
  def after_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    # Refresh Contribution List on requests show
    expire_fragments record.demande.fragments if record.demande
    expire_fragments record.fragments
  end
end
