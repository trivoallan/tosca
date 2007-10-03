class AddLastCommentId2request < ActiveRecord::Migration
  def self.up
    add_column :demandes, :last_comment_id, :integer, :default => 0, :null => false
    update("UPDATE demandes d " + 
           "SET last_comment_id=(SELECT c.id FROM commentaires c " + 
           "WHERE c.demande_id=d.id ORDER BY c.created_on DESC LIMIT 1)" + 
           "WHERE d.last_comment_id=0" )
  end

  def self.down
    remove_column :demandes, :last_comment_id
  end
end
