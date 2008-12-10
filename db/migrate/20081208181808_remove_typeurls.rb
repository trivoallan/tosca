class RemoveTypeurls < ActiveRecord::Migration
  def self.up
    drop_table :typeurls
    
    remove_column :urlsoftwares, :typeurl_id
  end

  def self.down
    create_table "typeurls", :force => true do |t|
      t.string "name", :default => "", :null => false
    end

    add_column :urlsoftwares, :typeurl_id, :integer
    
  end
end
