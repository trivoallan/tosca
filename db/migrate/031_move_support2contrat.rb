class MoveSupport2contract < ActiveRecord::Migration

  class Support < ActiveRecord::Base
    has_many :clients
  end
  class Client < ActiveRecord::Base
    belongs_to :support
    has_many :contracts
  end
  class Contract < ActiveRecord::Base
    belongs_to :client
  end

  def self.up
    add_column :contracts, :veille_technologique, :boolean, :default => false
    add_column :contracts, :newsletter, :boolean, :default => false
    add_column :contracts, :heure_ouverture, :integer, :default => 9, :null => false
    add_column :contracts, :heure_fermeture, :integer, :default => 18, :null => false
    Client.find(:all).each do |client|
      support = client.support
      client.contracts.each { |c|
        c.heure_ouverture = support.ouverture
        c.heure_fermeture = support.fermeture
        c.veille_technologique = support.veille_technologique
        c.newsletter = support.newsletter
        c.save
      }
    end
    drop_table :supports
    # needed 4 sqlite
    # remove_index :clients, :support_id
    remove_column :clients, :support_id
  end

  def self.down
    create_table "supports", :force => true do |t|
      t.column "name",                 :string
      t.column "maintenance",          :boolean, :default => false
      t.column "assistance_tel",       :boolean, :default => false
      t.column "veille_technologique", :boolean, :default => false
      t.column "ouverture",            :integer, :default => 0,     :null => false
      t.column "fermeture",            :integer, :default => 0,     :null => false
      t.column "newsletter",           :boolean
      t.column "duree_intervention",   :integer
    end
    add_column :clients, :support_id, :integer

    Client.find(:all).each do |client|
      support = Support.new
      client.contracts.each { |c|
        support.ouverture = c.heure_ouverture
        support.fermeture = c.heure_fermeture
        support.veille_technologique = c.veille_technologique
        support.newsletter = c.newsletter
        support.save
      }
      client.update_attribute(:support_id, support.id)
    end
    remove_column :contracts, :veille_technologique
    remove_column :contracts, :newsletter
    remove_column :contracts, :heure_ouverture
    remove_column :contracts, :heure_fermeture

  end

end
