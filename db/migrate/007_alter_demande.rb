class AlterDemande < ActiveRecord::Migration

  def self.up
    change_column :demandes, :reproductible, 
      :boolean, :default => false, :null => false
  end

  def self.down
    #pas de down
  end
end
