class SomeFields2English < ActiveRecord::Migration
  def self.up
    rename_column :changelogs, :date_modification, :modification_date
    rename_column :changelogs, :nom_modification, :name #Be more Tosca compatible
    rename_column :changelogs, :text_modification, :modification_text

    rename_column :commitments, :contournement, :workaround
  end

  def self.down
    rename_column :changelogs, :modification_date, :date_modification
    rename_column :changelogs, :name, :nom_modification
    rename_column :changelogs, :modification_text, :text_modification
    rename_column :commitments, :workaround, :contournement
  end
end
