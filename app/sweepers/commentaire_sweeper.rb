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
    expire_fragment("comments/#{record.id}/expert")
    expire_fragment("comments/#{record.id}/recipient")
    # Expire the right side, with the last comment
    expire_fragment("requests/#{record.demande_id}/front-expert")
    expire_fragment("requests/#{record.demande_id}/front-recipient")
    # Fragments for hsitory tab
    expire_fragment("requests/#{record.demande.id}/history")
  end
end
