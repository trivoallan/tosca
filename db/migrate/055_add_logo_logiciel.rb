class AddLogoLogiciel < ActiveRecord::Migration
  def self.up
    create_table :logos, :options => 'ENGINE=MyISAM CHARSET=utf8' do |t|
      t.column :image, :string, :null => false
      t.column :description, :string, :null => true
      t.column :logiciel_id, :integer, :null => false
    end

    add_column :logiciels, :logo_id, :integer, :null => true
    add_index :logiciels, :logo_id
    add_index :logos, :logiciel_id
  end

  def self.down
    #Faire le drop index AVANT le remove column sinon ça plante
    remove_index :logiciels, :logo_id
    remove_column :logiciels, :logo_id

    remove_index :logos, :logiciel_id
    drop_table :logos
  end
end
