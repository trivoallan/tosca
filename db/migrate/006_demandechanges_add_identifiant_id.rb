class DemandechangesAddIdentifiantId < ActiveRecord::Migration
  def self.up
    add_column :demandechanges, :identifiant_id, :integer, :null => false
  end

  def self.down
    remove_column :demandechanges, :identifiant_id
  end
end
