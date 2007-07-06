class AddIndex2contributions < ActiveRecord::Migration
  def self.up
    add_index :contributions, :logiciel_id
    add_index :contributions, :ingenieur_id
  end

  def self.down
    remove_index :contributions, :logiciel_id
    remove_index :contributions, :ingenieur_id
  end
end
