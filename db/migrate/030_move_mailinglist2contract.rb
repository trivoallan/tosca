class MoveMailinglist2contract < ActiveRecord::Migration
  class Contrat < ActiveRecord::Base; end
  class Client < ActiveRecord::Base; end

  def self.up
    add_column :contrats, :mailinglist, :string, :limit => 50, :null => false
    Client.find(:all).each do |cl|
      ml = cl.mailingliste
      cl.contrats.each { |co| co.update_attribute :mailinglist, ml }
    end
    remove_column :clients, :mailingliste
  end

  def self.down
    remove_column :contrats, :mailinglist
    add_column :clients, :mailingliste, :string, :limit => 50, :null => false
    Contrat.find(:all).each do |co|
      co.client.update_attribute :mailingliste, co.mailinglist
    end
  end
end
