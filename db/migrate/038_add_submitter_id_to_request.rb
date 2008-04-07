class AddSubmitterIdToRequest < ActiveRecord::Migration
  def self.up
    add_column :demandes, :submitter_id, :integer, :null => false, :default => 0
    update("UPDATE demandes d, beneficiaires b " <<
           "SET submitter_id=b.user_id WHERE b.id = d.beneficiaire_id")

    add_index :demandes, :submitter_id
  end

  def self.down
    remove_column :demandes, :submitter_id
  end
end
