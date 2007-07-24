class AddAvatarIngenieur < ActiveRecord::Migration
  def self.up
    add_column :ingenieurs, :image_id, :integer
  end

  def self.down
    remove_column :ingenieurs, :image_id
  end
end
