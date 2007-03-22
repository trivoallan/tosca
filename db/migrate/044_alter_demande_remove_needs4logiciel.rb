class AlterDemandeRemoveNeeds4logiciel < ActiveRecord::Migration
  def self.up
    change_column :demandes, :logiciel_id, :integer, :null => true
    change_column :demande_versions, :logiciel_id, :integer,:null => true
  end

  def self.down
    change_column :demandes, :logiciel_id, :integer, :null => false
    change_column :demande_versions, :logiciel_id, :integer, :null => false
  end
end
