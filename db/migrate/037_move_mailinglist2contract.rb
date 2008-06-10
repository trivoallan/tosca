class MoveMailinglist2contract < ActiveRecord::Migration
  class Contract < ActiveRecord::Base
    belongs_to :client
  end
  class Client < ActiveRecord::Base
    has_many :contracts
  end

  def self.up
    add_column :contracts, :mailinglist, :string,
      :limit => 50, :null => false, :default => ''
    Client.find(:all).each do |cl|
      ml = cl.mailingliste
      cl.contracts.each { |co| co.update_attribute :mailinglist, ml }
    end
    remove_column :clients, :mailingliste
  end

  def self.down
    add_column :clients, :mailingliste, :string, :limit => 50, :null => false
    Contract.find(:all).each do |co|
      co.client.update_attribute :mailingliste, co.mailinglist
    end
    remove_column :contracts, :mailinglist
  end
end
