class CleanIdentifiants < ActiveRecord::Migration
  def self.up
    remove_column :identifiants, :affichage_personnel
    remove_column :identifiants, :commentaires_count
  end

  def self.down
    add_column :identifiants, :affichage_personnel
    add_column :identifiants, :commentaires_count, :integer
  end
end
