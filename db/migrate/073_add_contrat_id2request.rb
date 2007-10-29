class AddContratId2request < ActiveRecord::Migration
  def self.up
    update("UPDATE demandes d SET contrat_id = " + 
            "(SELECT c.id FROM contrats c, beneficiaires b " + 
            "WHERE c.client_id=b.client_id AND b.id=d.beneficiaire_id) " +
           "WHERE d.contrat_id IS NULL OR d.contrat_id = 0")
  end

  def self.down
  end
end
