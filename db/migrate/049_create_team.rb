class AddTeam < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name, :motto
      t.integer :user_cache, :contact_id
    end
    
    create_table :users_teams do |t|
      t.integer :user_id, :team_id
    end
    add_index :users_teams, :user_id
    add_index :users_teams, :team_id
    
    create_table :contrats_teams do |t|
      t.integer :contrat_id, :team_id
    end
    add_index :contrats_teams, :contrat_id
    add_index :contrats_teams, :team_id
  end

  def self.down
    drop_table :teams
    drop_table :teams_contrats
    drop_table :teams_users
  end
end
