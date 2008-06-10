class AddTicketForRequests < ActiveRecord::Migration
  def self.up
    #For single table inherance
    add_column :contracts, :rule_type, :string, :null => false, :limit => 20, :default => ''
    add_column :contracts, :rule_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :contracts, :rule_type
    remove_column :contracts, :rule_id
  end
end
