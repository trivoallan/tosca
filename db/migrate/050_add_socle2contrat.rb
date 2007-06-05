class AddSocle2contrat < ActiveRecord::Migration
  def self.up
    add_column :contrats, :socle, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :contrats, :socle
  end
end
