class Identifiant2user < ActiveRecord::Migration
  COLUMNS = { 
    :titre => :title,
    :nom => :name,
    :telephone => :phone
  }

  def self.up
    drop_table(:users) # an error of youth
    rename_table(:identifiants, :users)
    COLUMNS.each { |key, value| 
      rename_column(:users, key, value) 
    }
    rename_column :ingenieurs, :identifiant_id, :user_id
    rename_column :beneficiaires, :identifiant_id, :user_id
    rename_column :commentaires, :identifiant_id, :user_id
    rename_column :document_versions, :identifiant_id, :user_id
    rename_column :documents, :identifiant_id, :user_id
    rename_column :preferences, :identifiant_id, :user_id
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
