class FixDemandeVersion < ActiveRecord::Migration
  def self.up
    rename_column :demande_versions, :piecejointe_id, :socle_id
  end

  def self.down
    rename_column :demande_versions, :socle_id, :piecejointe_id
  end
end
