class AddContactAndMailingList2contract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :commercial_id, :integer
    add_column :contracts, :customer_ml, :string
    rename_column :contracts, :mailinglist, :internal_ml
  end

  def self.down
    remove_column :contracts, :commercial_id
    remove_column :contracts, :customer_ml
    rename_column :contracts, :internal_ml, :mailinglist
  end
end
