class AddActiveColumn < ActiveRecord::Migration
  def self.up
    add_column :paquets, :active, :boolean, :default => true
  end

  def self.down
    remove_column :paquets, :active
  end
end
