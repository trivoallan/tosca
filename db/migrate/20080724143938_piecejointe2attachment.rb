class Piecejointe2attachment < ActiveRecord::Migration
  def self.up
    rename_table :piecejointes, :attachments
    rename_column :commentaires, :piecejointe_id, :attachment_id
  end

  def self.down
    rename_table :attachments, :piecejointes
    rename_column :commentaires, :attachment_id, :piecejointe_id
  end
end
