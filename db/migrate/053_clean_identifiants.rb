class CleanIdentifiants < ActiveRecord::Migration
  def self.up
    remove_column :identifiants, :affichage_personnel
    remove_column :identifiants, :commentaires_count
    remove_column :demandes, :reproductible
  end

  def self.down
    add_column :identifiants, :affichage_personnel
    add_column :identifiants, :commentaires_count, :integer
    add_column :demandes, :reproductible, :boolean
  end
end
