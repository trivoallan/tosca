class Engagments2english < ActiveRecord::Migration
  def self.up
    rename_table :contracts_engagements, :contracts_commitments
    rename_column :contracts_commitments, :engagement_id, :commitment_id
    add_index :contracts_commitments, :commitment_id

    rename_table :engagements, :commitments
    add_index :commitments, ["severite_id", "typedemande_id"], :name => "commitments_severite_id_index"
  end

  def self.down
    rename_table :contracts_commitments, :contracts_engagements
    rename_column :contracts_engagements, :commitment_id, :engagement_id
    add_index :contracts_engagements, :engagement_id

    rename_table :commitments, :engagements
    add_index :engagements, ["severite_id", "typedemande_id"], :name => "engagements_severite_id_index"
  end
end
