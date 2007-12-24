class LastCommentPublic < ActiveRecord::Migration
  def self.up
    update("UPDATE demandes SET last_comment_id = (" +
           "SELECT id FROM commentaires WHERE prive = 0 " + 
           "ORDER BY created_on DESC LIMIT 1" +
           ")")
  end

  def self.down
    update("UPDATE demandes SET last_comment_id = (" +
           "SELECT id FROM commentaires " + 
           "ORDER BY created_on DESC LIMIT 1" +
           ")")
  end
end

