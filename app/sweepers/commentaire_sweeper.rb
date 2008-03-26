class CommentaireSweeper < ActionController::Caching::Sweeper
  # All the cache used for comments are in the
  # 'comment' action of the 'request' controller.
  observe Commentaire

  # If our sweeper detects that a Comment was created call this
  def after_save(comment)
    expire_cache_for(comment)
  end

  # If our sweeper detects that a Comment was deleted call this
  def after_destroy(comment)
    expire_cache_for(comment)
  end

  private
  def expire_cache_for(record)
    expire_fragments(record.fragments)
    # Comments are displayed in request view
    expire_fragments(record.demande.fragments)
  end
end
