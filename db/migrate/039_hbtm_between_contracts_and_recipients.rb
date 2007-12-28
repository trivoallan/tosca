class HbtmBetweenContractsAndRecipients < ActiveRecord::Migration
  class Beneficiaire < ActiveRecord::Base
    belongs_to :client
    has_and_belongs_to_many :contrats
  end
  class Client < ActiveRecord::Base
    has_many :contrats
  end
  class Contrat < ActiveRecord::Base
    belongs_to :client
  end

  def self.up
    create_table :beneficiaires_contrats, :id => false do |t|
      t.column :beneficiaire_id, :integer
      t.column :contrat_id, :integer
    end
    add_index :beneficiaires_contrats, :beneficiaire_id
    add_index :beneficiaires_contrats, :contrat_id

    Beneficiaire.find(:all).each {|b|
      b.contrats = b.client.contrats
      b.save
    }
  end

  def self.down
    drop_table :beneficiaires_contrats
  end
end
