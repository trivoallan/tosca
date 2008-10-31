class AddAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.integer :team_id
      #The name "hash" is reserved for ActiveRecord
      t.string :hash_value
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
