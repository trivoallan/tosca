class RemoveClientIdFromSocles < ActiveRecord::Migration
  def self.up
    remove_column :socles, :client_id
  end

  def self.down
    add_column :socles, :client_id; :integer
  end

end
