class DropOlTables < ActiveRecord::Migration
  # Drop old legacy tables, they are not needed anymore.
  def self.up
    drop :old_bouquets
    drop :old_classifications
    drop :old_reversements
  end

  def self.down
  end
end
