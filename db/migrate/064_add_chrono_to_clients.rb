class AddChronoToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :chrono, :string
  end

  def self.down
    remove_column :clients, :chrono
  end
end
