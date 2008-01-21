class CreateRulesCredits < ActiveRecord::Migration
  def self.up
    rename_table :time_tickets, :credits
  end

  def self.down
    rename_table :credits, :time_tickets
  end
end
