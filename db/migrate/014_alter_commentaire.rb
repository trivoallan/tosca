class AlterCommentaire < ActiveRecord::Migration
  def self.up
    change_column :commentaires, :prive,
    :boolean, :default => false, :null => false
  end

  def self.down
  end
end
