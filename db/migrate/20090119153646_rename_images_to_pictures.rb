class RenameImagesToPictures < ActiveRecord::Migration
  def self.up
    rename_table(:images, :pictures)
  end

  def self.down
    rename_table(:pictures, :images)
  end
end
