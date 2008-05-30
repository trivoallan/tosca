class AddTeam < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name, :motto
      t.integer :user_cache, :contact_id
    end
    
    create_table :teams_users do |t|
      t.integer :user_id, :team_id
    end
    add_index :teams_users, :user_id
    add_index :teams_users, :team_id
    
    create_table :teams_contrats do |t|
      t.integer :contrat_id, :team_id
    end
    add_index :teams_contrats, :contrat_id
    add_index :teams_contrats, :team_id
  end

  def self.down
    drop_table :teams
    drop_table :teams_contrats
    drop_table :teams_users
  end
end
