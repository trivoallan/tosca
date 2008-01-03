class AddCacheTable < ActiveRecord::Migration
  def self.up
    create_table :elapseds do |t|
      t.integer :demande_id, :null => false
      t.integer :taken_into_account
      t.integer :workaround
      t.integer :correction
      t.integer :until_now
    end
    add_index :elapseds, :demande_id, :unique => true

    add_column :commentaires, :elapsed, :integer, :null => false, :default => 0
    add_column :demandes, :elapsed_id, :integer, :null => false
  end

  def self.down
    drop_table :elapseds
    remove_column :commentaires, :elapsed
  end
end
