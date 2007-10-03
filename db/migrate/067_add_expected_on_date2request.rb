class AddExpectedOnDate2request < ActiveRecord::Migration
  def self.up
    add_column :demandes, :expected_on, :datetime, :null => true
  end

  def self.down
    remove_column :demande, :expected_on
  end
end
