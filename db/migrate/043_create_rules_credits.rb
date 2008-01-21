class CreateRulesCredits < ActiveRecord::Migration
  def self.up
    rename_table :time_tickets, :credits
    Contrat.find(:all).each { |c|
      if c.rule_type == 'TimeTicket'
        c.update_attribute :rule_type, 'Rules::Credit'
      end
    }
  end

  def self.down
    rename_table :credits, :time_tickets
        Contrat.find(:all).each { |c|
      if c.rule_type == 'Rules::Credit'
        c.update_attribute :rule_type, 'TimeTicket'
      end
    }

  end
end
