class DropJourFerie < ActiveRecord::Migration
  def self.up
    drop_table "jourferies"
  end

  def self.down
    create_table "jourferies", :force => true do |t|
      t.column "jour", :timestamp, :null => false
    end
  end
end
