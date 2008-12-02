class Addtam < ActiveRecord::Migration
  def self.up
    add_column :contracts, :manager_id, :integer
  end

  def self.down
    remove_column :contracts, :manager_id
  end
end
