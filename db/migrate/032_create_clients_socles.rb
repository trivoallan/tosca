class CreateClientsSocles < ActiveRecord::Migration
  def self.up
    create_table :clients_socles, :id => false do |t|
      t.column :client_id, :integer
      t.column :socle_id, :integer
    end
    add_index :clients_socles, :client_id
    add_index :clients_socles, :socle_id

    add_column :demandes, :socle_id, :integer
  end

  def self.down
    drop_table :clients_socles
    remove_column :demandes, :socle_id
  end
end
