class UpdateContributionDates < ActiveRecord::Migration
  # Needed for a cleaner & coherent display, since the form accept
  # only dates in current version
  def self.up
    change_column :contributions, :reverse_le, :date
    change_column :contributions, :cloture_le, :date
  end

  def self.down
    change_column :contributions, :reverse_le, :datetime
    change_column :contributions, :cloture_le, :datetime
  end
end
