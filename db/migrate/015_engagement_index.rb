class EngagementIndex < ActiveRecord::Migration
  def self.up
    add_index :engagements, :severite_id
    add_index :engagements, :typedemande_id

    add_index :contrats_engagements, :contrat_id
    add_index :contrats_engagements, :engagement_id
  end

  def self.down
    remove_index :engagements, :severite_id
    remove_index :engagements, :typedemande_id
  end

end
