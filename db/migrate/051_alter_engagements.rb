class AlterEngagements < ActiveRecord::Migration
  def self.up
    change_column :engagements, :correction, :float
    change_column :engagements, :contournement, :float
  end

  def self.down
    change_column :engagements, :correction, :integer
    change_column :engagements, :contournement, :integer

  end
end
