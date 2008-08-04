class EnglishBeneficiaire2recipient < ActiveRecord::Migration
  def self.up
    # These columns were not used
    remove_column :beneficiaires, :notifier_subalternes
    remove_column :beneficiaires, :notifier
    remove_column :beneficiaires, :notifier_cc
    remove_column :beneficiaires, :beneficiaire_id
    rename_table :beneficiaires, :recipients

    rename_column :clients, :beneficiaires_count, :recipients_count
    rename_column :demandes, :beneficiaire_id, :recipient_id
    rename_column :phonecalls, :beneficiaire_id, :recipient_id
  end

  def self.down
    # ActiveRecord::IrreversibleMigration
  end
end
