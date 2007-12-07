class AddTicketForRequests < ActiveRecord::Migration
  def self.up
    #For single table inherance
    add_column :contrats, :type, :string

    add_column :contrats, :tickets_total,     :integer, :default => 0
    add_column :contrats, :tickets_consommes, :integer, :default => 0
    add_column :contrats, :ticket_temps,      :float, :default => 15

    Contrat.find(:all).each do |c|
      c.support? ? c[:type] = "Support" : c[:type] = "Ossa"
      c.save
    end
    remove_column :contrats, :support
  end

  def self.down
    add_column :contrats, :support, :boolean, :default => false
    remove_column :contrats, :type
    remove_column :contrats, :tickets_total
    remove_column :contrats, :tickets_consommes
    remove_column :contrats, :ticket_temps
  end
end
