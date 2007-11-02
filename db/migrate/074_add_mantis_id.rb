class AddMantisId < ActiveRecord::Migration
  def self.up
    add_column :demandes, :mantis_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :demandes, :mantis_id
  end
end
