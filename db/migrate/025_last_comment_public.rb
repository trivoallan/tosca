class LastCommentPublic < ActiveRecord::Migration
  def self.up
    update("UPDATE demandes d SET d.last_comment_id = (" +
           "SELECT id FROM commentaires c WHERE c.prive = 0 AND c.demande_id = d.id " +
           "ORDER BY created_on DESC LIMIT 1" +
           ")")
  end

  def self.down
    update("UPDATE demandes d SET last_comment_id = (" +
           "SELECT id FROM commentaires c WHERE c.demande_id = d.id  " +
           "ORDER BY created_on DESC LIMIT 1" +
           ")")
  end
end
