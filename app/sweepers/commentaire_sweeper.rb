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
    # Expire the 2 fragments used in 'demandes/comment'
    # The 'true/false' parameter is used to have 2 caches
    # depending the user profile (expert or recipient ?).
    expire_fragment("#{record.id}/comments")
    # Expire the right side, with the last comment
    expire_fragment("#{record.demande_id}/true/requests/front")
    expire_fragment("#{record.demande_id}/false/requests/front")
  end
end
