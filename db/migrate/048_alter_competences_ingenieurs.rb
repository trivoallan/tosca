class AlterCompetencesIngenieurs < ActiveRecord::Migration
  def self.up
    add_column :competences_ingenieurs, :niveau, :integer
  end

  def self.down
    remove_column :competences_ingenieurs, :niveau
  end
end
