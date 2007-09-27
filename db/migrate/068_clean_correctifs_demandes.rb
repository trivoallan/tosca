class CleanCorrectifsDemandes < ActiveRecord::Migration
  def self.up
    drop_table :correctifs_demandes
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
