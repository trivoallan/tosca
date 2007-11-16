class Document2english < ActiveRecord::Migration
  FICHIER = File.expand_path(RAILS_ROOT) + "/files/document/fichier/"
  FILE = File.expand_path(RAILS_ROOT) + "/files/document/file/"
  def self.up
    rename_column :documents, :titre, :title
    rename_column :documents, :fichier, :file

    rename_column :document_versions, :titre, :title
    rename_column :document_versions, :fichier, :file

    File.rename(FICHIER, FILE)
  end

  def self.down
    rename_column :documents, :title, :titre
    rename_column :documents, :file, :fichier

    rename_column :document_versions, :title, :titre
    rename_column :document_versions, :file, :fichier

    File.rename(FILE, FICHIER)
  end
end
