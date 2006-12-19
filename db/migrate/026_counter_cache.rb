class CounterCache < ActiveRecord::Migration
  def self.up
    add_column :paquets, :fichiers_count, :integer
    add_column :paquets, :changelogs_count, :integer
    add_column :contrats, :paquets_count, :integer
    add_column :projets, :taches_count, :integer
    add_column :socles, :paquets_count, :integer
    add_column :socles, :demandes_count, :integer
    add_column :clients, :beneficiaires_count, :integer
    add_column :identifiants, :commentaires_count, :integer
    add_column :logiciels, :interactions_count, :integer
    add_column :ingenieurs, :interactions_count, :integer
  end

  def self.down
    remove_column :paquets, :fichiers_count, :integer
    remove_column :paquets, :changelogs_count, :integer
    remove_column :contrats, :paquets_count, :integer
    remove_column :projets, :taches_count, :integer
    remove_column :socles, :paquets_count, :integer
    remove_column :socles, :demandes_count, :integer
    remove_column :clients, :beneficiaires_count, :integer
    remove_column :identifiants, :commentaires_count, :integer
    remove_column :logiciels, :interactions_count, :integer
    remove_column :ingenieurs, :interactions_count, :integer
  end
end
