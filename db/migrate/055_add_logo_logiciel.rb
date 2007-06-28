class AddLogoLogiciel < ActiveRecord::Migration
  def self.up
    add_column :logiciels, :image_id, :integer, :null => true
    add_index :logiciels, :image_id

#     remove_index :clients, :photo_id
    rename_column :clients, :photo_id, :image_id
    add_index :clients, :image_id

#     remove_index :identifiants, :photo_id
    rename_column :identifiants, :photo_id, :image_id
    add_index :identifiants, :image_id

    rename_table :photos, :images
  end

  def self.down
    rename_table :images, :photos

    remove_index :logiciels, :image_id
    remove_column :logiciels, :image_id

    remove_index :clients, :image_id
    rename_column :clients, :image_id, :photo_id
#     add_index :clients, :photo_id

    remove_index :identifiants, :image_id
    rename_column :identifiants, :image_id, :photo_id
#     add_index :identifiants, :photo_id
  end
end
