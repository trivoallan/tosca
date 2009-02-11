class RemoveSpecificFieldContracts < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :obligation
    remove_column :contracts, :technological_survey
    remove_column :contracts, :newsletter
  end

  def self.down
    add_column :contracts, :obligation, :boolean
    add_column :contracts, :technological_survey, :boolean
    add_column :contracts, :newsletter, :boolean
  end
end
