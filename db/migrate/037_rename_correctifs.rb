class RenameCorrectifs < ActiveRecord::Migration

  # renommage des correctifs en contribution
  def self.up
    rename_table :correctifs, :contributions
    rename_column :urlreversements, :correctif_id, :contribution_id
    rename_column :demandes, :correctif_id, :contribution_id
    rename_column :demande_versions, :correctif_id, :contribution_id

    rename_table :binaires_correctifs, :binaires_contributions
    rename_column :binaires_contributions, :correctif_id, :contribution_id

    rename_table :correctifs_paquets, :contributions_paquets
    rename_column :contributions_paquets, :correctif_id, :contribution_id
  end

  def self.down
    rename_table :contributions, :correctifs 
    rename_column :urlreversements, :contribution_id, :correctif_id
    rename_column :demandes, :contribution_id, :correctif_id
    rename_column :demande_versions, :contribution_id, :correctif_id

    rename_table :binaires_contributions, :binaires_correctifs 
    rename_column :binaires_contributions, :contribution_id, :correctif_id

    rename_table :contributions_paquets, :correctifs_paquets 
    rename_column :contributions_paquets, :contribution_id, :correctif_id
  end

end
