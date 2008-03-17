class AddSubmitterIdToRequest < ActiveRecord::Migration
  def self.up
    add_column :demandes, :submitter_id, :integer, :null => false, :default => 0
    update("UPDATE demandes SET submitter_id=" <<
           "(SELECT b.user_id FROM beneficiaires b " <<
            "WHERE b.id = beneficiaire_id)")

    add_index :demandes, :submitter_id
  end

  def self.down
    remove_column :demandes, :submitter_id
  end
end
