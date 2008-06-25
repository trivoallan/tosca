class RenameFieldDemandeIdToContractIdInTags < ActiveRecord::Migration
  def self.up
    rename_column :tags, :demande_id, :contract_id
  end

  def self.down
    rename_column :tags, :contract_id, :demande_id
  end
end 
