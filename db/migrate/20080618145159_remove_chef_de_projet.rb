class RemoveChefDeProjet < ActiveRecord::Migration
  def self.up
    remove_column :ingenieurs, :chef_de_projet
  end

  def self.down
    add_column :ingenieurs, :chef_de_projet, :boolean, :default => false, :null => false
  end
end
