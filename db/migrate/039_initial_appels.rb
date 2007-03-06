class InitialAppels < ActiveRecord::Migration
  def self.up
    create_table :appels do |t|
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
