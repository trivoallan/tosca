class DropDemandechange < ActiveRecord::Migration
  def self.up
    drop_table :demandechanges
  end

  def self.down
    create_table "demandechanges", :force => true do |t|
      t.column "demande_id", :integer, :default => 0, :null => false
      t.column "statut_id", :integer, :default => 0, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "identifiant_id", :integer, :default => 0, :null => false
    end

    add_index "demandechanges", ["identifiant_id"], :name => "demandechanges_identifiant_id_index"
    add_index "demandechanges", ["demande_id"], :name => "demandechanges_demande_id_index"
  end
end
