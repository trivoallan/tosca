class CreateCorrectifsPaquets < ActiveRecord::Migration
  def self.up
    create_table :correctifs_paquets, :id => false do |t|
      t.column :correctif_id, :integer, :null => false
      t.column :paquet_id, :integer, :null => false
    end
    add_index :documents, :typedocument_id
    add_index :documents, :client_id
    add_column :correctifs, :logiciel_id, :integer, :null => false
    add_index :correctifs, :logiciel_id
  end

  def self.down
    drop_table :correctifs_paquets
    remove_column :correctifs, :logiciel_id
  end
end
