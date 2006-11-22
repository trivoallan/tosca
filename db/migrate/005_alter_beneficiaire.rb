class AlterBeneficiaire < ActiveRecord::Migration
  def self.up
    change_column :beneficiaires, :notifier, 
      :boolean, :default => true, :null => false
    change_column :beneficiaires, :notifier_cc, 
      :boolean, :default => true, :null => false
    change_column :beneficiaires, :notifier_subalternes, 
      :boolean, :default => true, :null => false
  end

  #pas de retour en arrière cette fois ci
  def self.down
  end
end
