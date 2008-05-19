class ChangePreferences < ActiveRecord::Migration
  def self.up
    #easier...
    drop_table :preferences
    create_table :preferences do |t|
      t.string :attribute, :null => false
      t.references :owner, :polymorphic => true, :null => false
      t.references :preferenced, :polymorphic => true
      t.string :value
      t.timestamps
    end
    add_index :preferences, [:owner_id, :owner_type, :attribute, :preferenced_id, :preferenced_type], :unique => true, :name => 'index_preferences_on_owner_and_attribute_and_preference'
  end

  def self.down
    drop_table :preferences
    create_table "preferences", :force => true do |t|
      t.column "identifiant_id", :integer,                    :null => false
      t.column "mail_text",      :boolean, :default => false
      t.column "all_mail",       :boolean, :default => true
      t.column "digest_daily",   :boolean, :default => false
      t.column "digest_weekly",  :boolean, :default => false
    end
    add_index "preferences", ["identifiant_id"]
  end
end
