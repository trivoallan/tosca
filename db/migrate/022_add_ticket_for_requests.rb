class AddTicketForRequests < ActiveRecord::Migration
  def self.up
    #For single table inherance
    add_column :contrats, :rule_type, :string, :null => false, :limit => 20
    add_column :contrats, :rule_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :contrats, :rule_type
    remove_column :contrats, :rule_id
  end
end
