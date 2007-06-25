class AddPreferencesUsers < ActiveRecord::Migration
  def self.up
    create_table :preferences, :options => 'ENGINE=MyISAM CHARSET=utf8' do |t|
      t.column :identifiant_id, :integer, :null => false
      t.column :mail_html, :boolean, :default => false
    end
    add_index :preferences, :identifiant_id
  end

  def self.down
    drop_table :preferences
  end
end
