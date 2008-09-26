class LogicielInEnglish < ActiveRecord::Migration
  def self.up
    # There's not softwares in english, only software.
    # But it's way too easier to manage it that way
    rename_table :logiciels, :softwares

    rename_table :competences_logiciels, :competences_softwares
    rename_column :competences_softwares, :logiciel_id, :software_id

    rename_column :contributions, :logiciel_id, :software_id
    rename_column :images, :logiciel_id, :software_id
    rename_column :knowledges, :logiciel_id, :software_id
    rename_column :requests, :logiciel_id, :software_id
    rename_column :versions, :logiciel_id, :software_id

    rename_table :urllogiciels, :urlsoftwares
    rename_column :urlsoftwares, :logiciel_id, :software_id
  end

  def self.down
    rename_table :softwares, :logiciels

    rename_column :competences_softwares, :software_id, :logiciel_id
    rename_table :competences_softwares, :competences_logiciels

    rename_column :contributions, :software_id, :logiciel_id
    rename_column :images, :software_id, :logiciel_id
    rename_column :knowledges, :software_id, :logiciel_id
    rename_column :requests, :software_id, :logiciel_id
    rename_column :versions, :software_id, :logiciel_id

    rename_column :urlsoftwares, :software_id, :logiciel_id
    rename_table :urlsoftwares, :urllogiciels
  end
end
