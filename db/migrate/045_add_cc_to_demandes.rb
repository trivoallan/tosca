class AddCcToDemandes < ActiveRecord::Migration
  def self.up
     add_column :demandes, :mail_cc, :string, :null => true
  end

  def self.down
  end
end
