class Nom2nameOverall < ActiveRecord::Migration
  TABLES = %w(arches binaires clients communautes competences
              conteneurs contrats contributions dependances
              distributeurs etatreversements groupes
              licenses logiciels mainteneurs paquets roles severites statuts
              socles supports typecontributions typedemandes
              typedocuments typeurls)

  def self.up
    TABLES.each{|t| rename_column t, :nom, :name }
    drop_table 'etapes'
  end

  def self.down
    TABLES.each{|t| rename_column t, :name, :nom }
    create_table "etapes", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text
    end
  end
end
