class InitialAppels < ActiveRecord::Migration
  def self.up
    # TODO : surcharger le create_table pour forcer cette option
    # ou mieux : la configuration de MySQL
    create_table(:appels, :options => 
                 'ENGINE=MyISAM DEFAULT CHARSET=utf8') do |t|
      t.column :beneficiaire_id, :integer
      t.column :ingenieur_id, :integer
      t.column :debut, :timestamp
      t.column :fin, :timestamp
    end
    add_index :appels, :beneficiaire_id
    add_index :appels, :ingenieur_id
  end

  def self.down
    drop_table :appels
  end
end
