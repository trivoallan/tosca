class Identifiant2user < ActiveRecord::Migration
  COLUMNS = {
    :titre => :title,
    :nom => :name,
    :telephone => :phone
  }

  def self.up
    # Two errors of youth. they are rescued because only present on
    # some old prod databases ;).
    begin; drop_table(:users); rescue; end
    begin
      drop_table(:fournisseurs)
      remove_column :paquets, :fournisseur_id
    rescue; end

    rename_table(:identifiants, :users)
    COLUMNS.each { |key, value|
      rename_column(:users, key, value)
    }
    tables = [ :ingenieurs, :beneficiaires, :commentaires,
               :documents, :preferences ]
    tables.each do |t|
      remove_index t, :identifiant_id
      rename_column t, :identifiant_id, :user_id
      add_index t, :user_id
    end

    rename_column :document_versions, :identifiant_id, :user_id
  end

  def self.down
    rename_table(:users, :identifiants)
    COLUMNS.each { |key, value|
      rename_column(:identifiants, value, key)
    }
    rename_column :ingenieurs, :user_id, :identifiant_id
    rename_column :beneficiaires, :user_id, :identifiant_id
    rename_column :commentaires, :user_id, :identifiant_id
    rename_column :document_versions, :user_id, :identifiant_id
    rename_column :documents, :user_id, :identifiant_id
    rename_column :preferences, :user_id, :identifiant_id
  end
end
