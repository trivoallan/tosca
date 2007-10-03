class AddCreatedOnIndexes < ActiveRecord::Migration
  def self.up
    add_index :demandes, :created_on
    add_index :demandes, :updated_on
    add_index :commentaires, :created_on
    add_index :commentaires, :updated_on
  end

  def self.down
    drop_index :demandes, :created_on
    drop_index :demandes, :updated_on
    drop_index :commentaires, :created_on
    drop_index :commentaires, :updated_on
  end
end
