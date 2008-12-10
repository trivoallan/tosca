class RenameEtatcontribution2Contributionstate < ActiveRecord::Migration
  def self.up
    rename_table :etatreversements, :contributionstates
    
    rename_column :contributions, :etatreversement_id, :contributionstate_id
  end

  def self.down
    rename_table :contributionstates, :etatreversements
    
    rename_column :contributions, :contributionstate_id, :etatreversement_id
  end
end
