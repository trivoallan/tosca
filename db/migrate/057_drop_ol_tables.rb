class DropOlTables < ActiveRecord::Migration
  # Drop old legacy tables, they are not needed anymore.
  def self.up
    drop_table :old_bouquets
    drop_table :old_classifications
    drop_table :old_reversements
  end

  def self.down
  end
end
