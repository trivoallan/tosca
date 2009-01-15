class RemoveMantisId < ActiveRecord::Migration
  def self.up
    remove_column :contributions, :id_mantis
  end

  def self.down
    add_column :contributions, :id_mantis, :integer
  end
end
