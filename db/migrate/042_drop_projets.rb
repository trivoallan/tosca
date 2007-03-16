class DropProjets < ActiveRecord::Migration
  def self.up
    drop_table :echanges
    drop_table :projets
    drop_table :taches

    drop_table :ingenieurs_projets
    drop_table :logiciels_projets
    drop_table :beneficiaires_projets
  end

  # no down, this was not used anyway
  def self.down
  end
end
