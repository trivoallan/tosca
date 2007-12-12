class AddCacheTemps < ActiveRecord::Migration
  def self.up
    add_column :demandes, :cache_contournement, :float, :null=>true
    add_column :demandes, :cache_correction, :float, :null=>true
    add_column :demandes, :cache_ecoule, :float, :null=>true
    add_column :demandes, :cache_rappel, :float, :null=>true
  end

  def self.down
    remove_column :demandes, :cache_contournement
    remove_column :demandes, :cache_correction
    remove_column :demandes, :cache_ecoule
    remove_column :demandes, :cache_rappel
  end
end
