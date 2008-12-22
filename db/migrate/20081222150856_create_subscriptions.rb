class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id, :null => false
      t.integer :model_id, :null => false
      t.string :model_type, :null => false
      t.datetime :updated_on
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :model_id
  end

  def self.down
    remove_index :subscriptions, :column => :user_id
    remove_index :subscriptions, :column => :model_id

    drop_table :subscriptions
  end
end
