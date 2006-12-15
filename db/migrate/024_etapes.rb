class Etapes < ActiveRecord::Migration
  def self.up
    create_table :etapes do |t|
      t.column :nom, :string, :null => false
      t.column :description, :text
    end
  end

  def self.down
    drop_table :etapes
  end
end
