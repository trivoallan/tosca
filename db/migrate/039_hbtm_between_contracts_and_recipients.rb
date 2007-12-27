class HbtmBetweenContractsAndRecipients < ActiveRecord::Migration
  def self.up
    create_table :beneficiaires_contrats, :id => false do |t|
      t.column :beneficiaire_id, :integer
      t.column :contrat_id, :integer
    end
    add_index :beneficiaires_contrats, :beneficiaire_id
    add_index :beneficiaires_contrats, :contrat_id
  end

  def self.down
    drop_table :beneficiaires_contrats
  end
end
