class DropArches < ActiveRecord::Migration
  def self.up
    drop_table :arches
  end

  def self.down
    create_table "arches", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
    end
  end
end
