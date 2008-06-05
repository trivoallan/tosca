class AddCreatedBy < ActiveRecord::Migration
  class Client < ActiveRecord::Base; end
  class Contrat < ActiveRecord::Base; end

  def self.up
    add_column :clients, :creator_id, :integer, :null => false
    add_column :contrats, :creator_id, :integer, :null => false
    Client.update_all("creator_id = 1")
    Contrat.update_all("creator_id = 1")
  end

  def self.down
    remove_column :clients, :created_by
    remove_column :contrats, :created_by
  end
end
