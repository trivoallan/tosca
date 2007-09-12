class AddContractToRequest < ActiveRecord::Migration
  def self.up
    add_column :demandes, :contrat_id, :integer, :null => false
    add_index :demandes, :contrat_id
    add_column :contrats, :nom, :string

    # those indexes will slow SQL query
    remove_index :commentaires, :severite_id
    remove_index :commentaires, :statut_id

    update("UPDATE demandes d, beneficiaires b SET d.contrat_id=" <<
           "(SELECT co.id FROM contrats co INNER JOIN clients cl " <<
           "ON co.client_id=cl.id WHERE " << 
           "b.id=d.beneficiaire_id AND b.client_id=cl.id)")
    add_column :contrats, :support, :boolean, :default => false

    contracts = Contrat.find(:all, :include => [:client])
    contracts.each do |c|
      nom = "OSSA - #{c.client.nom} "
      nom << " - 24h/24" if c.astreinte
      nom << " - Intégrale" if c.socle 
      c.update_attribute(:nom, nom)
    end
  end

  def self.down
    remove_column :demandes, :contrat_id
    remove_column :contrats, :support
    remove_column :contrats, :nom
    add_index :commentaires, :severite_id
    add_index :commentaires, :statut_id
  end
end
