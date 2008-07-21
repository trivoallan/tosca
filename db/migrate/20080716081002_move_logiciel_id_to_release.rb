class MoveLogicielIdToRelease < ActiveRecord::Migration
  
  class Version < ActiveRecord::Base
    belongs_to :logiciel
    has_many :releases
  end
  
  def self.up
    add_column :releases, :logiciel_id, :integer
    
    Version.all.each do |v|
      v.releases.each do |r|
        r.logiciel_id = v.logiciel_id
        r.save
      end
    end
  end

  def self.down
  end
end
