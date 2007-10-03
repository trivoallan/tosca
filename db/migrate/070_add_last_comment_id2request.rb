class AddLastCommentId2request < ActiveRecord::Migration
  def self.up
    add_column :demandes, :last_comment_id, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :demandes, :last_comment_id
  end
end
