class HbtmBetweenContractsAndRecipients < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_one :beneficiaire
    has_one :ingenieur
    has_and_belongs_to_many :contrats
  end
  class Ingenieur < ActiveRecord::Base
    has_and_belongs_to_many :contrats
    belongs_to :user, :dependent => :destroy
  end
  class Beneficiaire < ActiveRecord::Base
    belongs_to :client
    belongs_to :user, :dependent => :destroy
  end
  class Client < ActiveRecord::Base
    has_many :contrats
  end
  class Contrat < ActiveRecord::Base
    belongs_to :client
  end

  # Move contracts to user, since it's now the same
  # for Recipient AND Engineers.
  def self.up
    create_table :contrats_users, :id => false do |t|
      t.column :user_id, :integer
      t.column :contrat_id, :integer
    end
    add_index :contrats_users, :user_id
    add_index :contrats_users, :contrat_id

    Beneficiaire.find(:all).each {|b|
      b.user.contrats = b.client.contrats
      b.user.save
    }
    Ingenieur.find(:all).each { |i|
      i.user.contrats = i.contrats
      i.user.save
    }
    drop_table :contrats_ingenieurs
  end

  def self.down
    create_table :contrats_ingenieurs, :id => false do |t|
      t.column :ingenieur_id, :integer
      t.column :contrat_id, :integer
    end
    add_index :contrats_ingenieurs, :ingenieur_id
    add_index :contrats_ingenieurs, :contrat_id

    Ingenieur.find(:all).each { |i|
      i.contrats = i.user.contrats
      i.save
    }
    drop_table :contrats_users
  end
end
