class CreateRulesTable < ActiveRecord::Migration
  class Contract < ActiveRecord::Base; end

  def self.up
    create_table :time_tickets do |t|
      t.column :name,   :string, :null => false
      # maximum number of time-tickets
      t.column :max,    :integer, :default => 20
      # time of a ticket
      t.column :time,   :float, :default => 0.25
    end

    create_table :ossas do |t|
      t.column :name,           :string, :null => false
      # maximum number of components. -1 => all components of the earth
      t.column :max,            :integer, :default => -1
    end

    Contract.find(:all).each do |c|
      if c.support?
        c[:rule_type] = 'Rules::Credit'
      else
        c[:rule_type] = "Ossa"
      end
      c[:rule_id] = 1
      c.name = '' # reset of their name, more easier since the state of the past
      c.save
    end
    remove_column :contracts, :support
    remove_column :contracts, :socle
  end

  def self.down
    drop_table :ossas
    drop_table :time_tickets
    add_column :contracts, :support, :boolean, :default => false, :null => false
    add_column :contracts, :socle, :boolean, :default => false, :null => false
  end
end
