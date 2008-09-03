class AddContactAndMailingList2contract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :commercial_id, :integer
    add_column :contracts, :customer_ml, :string
  end

  def self.down
    remove_column :contracts, :commercial_id
    remove_column :contracts, :customer_ml
  end
end
