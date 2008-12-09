class Groupe2Group < ActiveRecord::Migration
  def self.up
    rename_table :groupes, :groups
    rename_column :softwares, :groupe_id, :group_id
  end

  def self.down
    rename_table :groups, :groupes
    rename_column :softwares, :group_id, :groupe_id
  end
end
