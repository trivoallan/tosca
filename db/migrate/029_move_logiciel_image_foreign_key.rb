class MoveLogicielImageForeignKey < ActiveRecord::Migration
  def self.up
    add_column :images, :logiciel_id, :integer
    # Needed 4 sqlite
    remove_index :logiciels, :image_id
    remove_column :logiciels, :image_id
  end

  def self.down
    remove_column :images, :logiciel_id
    add_column :logiciels, :image_id, :integer
  end
end
