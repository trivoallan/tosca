class AddAffichagePersonnel < ActiveRecord::Migration
  def self.up
    add_column :identifiants, :affichage_personnel, 
      :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :identifiants, :affichage_personnel
  end
end
