class CreateTeam < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name, :motto
      t.integer :user_cache, :contact_id
    end

    #This is a table for has_and_belongs_to_many
    create_table :contrats_teams, :id => false do |t|
      t.integer :contrat_id, :team_id
    end
    add_index :contrats_teams, :contrat_id
    add_index :contrats_teams, :team_id
    
    add_column :users, :team_id, :integer
    add_index :users, :team_id
  end

  def self.down
    drop_table :teams
    drop_table :contrats_teams
    
    remove_index :users, :team_id
    remove_column :users, :team_id
  end
end
