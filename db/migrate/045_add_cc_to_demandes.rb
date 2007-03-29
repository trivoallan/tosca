class AddCcToDemandes < ActiveRecord::Migration
  def self.up
     add_column :demandes, :cc, :string, :null => true
  end

  def self.down
  end
end
