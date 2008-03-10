class MoveChronoNumber2contract < ActiveRecord::Migration

  class Client < ActiveRecord::Base
    has_many :contrats
  end
  class Contrat < ActiveRecord::Base
    belongs_to :client
  end

  def self.up
    add_column :contrats, :chrono, :integer, :default => 0, :null => false
    Client.find(:all).each do |client|
      client.contrats.each {|c| c.update_attribute(:chrono, client.chrono)}
    end
    remove_column :clients, :chrono
  end

  def self.down
    add_column :clients, :chrono, :integer, :default => 0, :null => false
    Client.find(:all).each do |client|
      client.contrats.each {|c| client.update_attribute(:chrono, c.chrono)}
    end
    remove_column :contrats, :chrono
  end

end
