class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news, :options => 'ENGINE=MyISAM CHARSET=utf8' do |t|
      t.column :subject, :string, :null => false
      t.column :source, :string, :null => false
      t.column :body, :text
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :ingenieur_id, :integer, :null => false
      t.column :client_id, :integer, :null => true
      t.column :logiciel_id, :integer, :null => false
    end
    add_index :news, :ingenieur_id
    add_index :news, :logiciel_id
    add_index :news, :subject
  end

  def self.down
    drop_table :news
  end
end
