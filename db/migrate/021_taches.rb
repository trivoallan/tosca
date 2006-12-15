class Taches < ActiveRecord::Migration
  def self.up
    create_table :taches do |t|
      t.column :created_on, :timestamp, :null => false
      t.column :updated_on, :timestamp, :null => false
      t.column :projet_id, :integer, :null => false
      t.column :duree, :float, :default => 1.0, :null => false
      t.column :deadline, :timestamp, :null => true
      t.column :resume, :string, :null => false
      t.column :description, :text, :null => true
      t.column :termine, :boolean, :null => false, :default => false
      t.column :position, :integer
      t.column :auteur_id, :integer, :null => false # ingenieur_id ?
      t.column :responsable_id, :integer, :null => false  # ingenieur_id ?
      t.column :etape_id, :integer
    end

    add_column :identifiants, :client, :boolean, :null => false
    add_column :ingenieurs, :chef_de_projet, :boolean, :null => false
    add_column :ingenieurs, :expert_ossa, :boolean, :null => false

    add_index :taches, :auteur_id
    add_index :taches, :responsable_id
    add_index :taches, :projet_id
    
  end

  def self.down
    drop_table :taches

    removecolumn :identifiants, :client
    removecolumn :ingenieurs, :chef_de_projet
    removecolumn :ingenieurs, :expert_ossa

    remove_index :taches, :auteur_id
    remove_index :taches, :responsable_id
  end
end
