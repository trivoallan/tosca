class CreateRulesComponents < ActiveRecord::Migration
  def self.up
    rename_table :ossas, :components
    Contrat.find(:all).each { |c|
      if c.rule_type == 'Ossa'
        c.update_attribute :rule_type, 'Rules::Component'
      end
    }
  end

  def self.down
    rename_table :components, :ossas
    Contrat.find(:all).each { |c|
      if c.rule_type == 'Rules::Component'
        c.update_attribute :rule_type, 'Ossa'
      end
    }
  end
end
