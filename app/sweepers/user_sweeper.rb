class UserSweeper < ActionController::Caching::Sweeper
  # Currently used to maintain cache correctly for request & comments
  observe User

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
    # Refresh User Info on each cache displaying it
    record.commentaires.each { |c| expire_fragments c.fragments }
    record.beneficiaire.demandes.each { |r| expire_fragments r.fragments }
  end
end
