class RenameImagesToPictures < ActiveRecord::Migration
  def self.up
    rename_table :images, :pictures

    rename_column :clients, :image_id, :picture_id
    rename_column :users, :image_id, :picture_id

    FileUtils.mv File.join(RAILS_ROOT, 'public', 'image'),
      File.join(RAILS_ROOT, 'public', 'picture'), :force => true
  end

  def self.down
    rename_table :pictures, :images

    rename_column :clients, :picture_id, :image_id
    rename_column :users, :picture_id, :image_id
  end
end
