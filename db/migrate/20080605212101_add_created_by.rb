class AddCreatedBy < ActiveRecord::Migration
  class Client < ActiveRecord::Base; end
  class Contract < ActiveRecord::Base; end

  def self.up
    add_column :clients, :creator_id, :integer, :null => false
    add_column :contracts, :creator_id, :integer, :null => false
    Client.update_all("creator_id = 1")
    Contract.update_all("creator_id = 1")
  end

  def self.down
    remove_column :clients, :created_by
    remove_column :contracts, :created_by
  end
end
