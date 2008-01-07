class AddBinaireId2request < ActiveRecord::Migration
  def self.up
    drop_table :demandes_paquets
    drop_table :binaires_demandes

    add_column :demandes, :binaire_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :demandes, :binaire_id, :integer, :null => true, :default => nil

    create_table "demandes_paquets", :id => false, :force => true do |t|
      t.column "paquet_id",  :integer, :default => 0, :null => false
      t.column "demande_id", :integer, :default => 0, :null => false
    end
    add_index "demandes_paquets", ["paquet_id"], :name => "demandes_paquets_paquet_id_index"
    add_index "demandes_paquets", ["demande_id"], :name => "demandes_paquets_demande_id_index"

    create_table "binaires_demandes", :id => false, :force => true do |t|
      t.column "binaire_id", :integer
      t.column "demande_id", :integer
    end
    add_index "binaires_demandes", ["binaire_id"], :name => "binaires_demandes_binaire_id_index"
    add_index "binaires_demandes", ["demande_id"], :name => "binaires_demandes_demande_id_index"

  end
end
