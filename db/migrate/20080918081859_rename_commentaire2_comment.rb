class RenameCommentaire2Comment < ActiveRecord::Migration
  def self.up
    rename_table :commentaires, :comments
    rename_column :comments, :corps, :text
    rename_column :comments, :prive, :private
  end

  def self.down
#    rename_table  :comments, :commentaires
    rename_column :commentaires, :text, :corps
    rename_column :commentaires, :private, :prive
  end
end
