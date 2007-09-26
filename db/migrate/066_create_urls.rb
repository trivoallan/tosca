class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls, :options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.column :resource_id, :integer
      t.column :resource_type, :string
      t.column :value, :string
      t.column :typeurl_id, :integer
    end
  end

  def self.down
    drop_table :urls
  end
end
