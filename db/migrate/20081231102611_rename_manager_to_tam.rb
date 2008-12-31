class RenameManagerToTam < ActiveRecord::Migration
  def self.up
    rename_column :contracts, :manager_id, :tam_id
  end

  def self.down
    rename_column :contracts, :tam_id, :manager_id
  end
end
