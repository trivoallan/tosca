class Urlsoftware < ActiveRecord::Base
    belongs_to :software
  end

class Contributionurl < ActiveRecord::Base
    belongs_to :contribution
end

class CreateUrls < ActiveRecord::Migration
  
  def self.up
    create_table :hyperlinks do |t|
      t.string :name
      t.string :model_type
      t.integer :model_id
    end

    Urlsoftware.all.each do |url|
      u = Hyperlink.new({:model_type => "software",
        :model_id => url.software_id,
        :name => url.valeur
      })
      u.save
    end

    Contributionurl.all.each do |url|
      u = Hyperlink.new({:model_type => "contribution",
        :model_id => url.contribution_id,
        :name => url.valeur
      })
      u.save
    end

    drop_table :urlsoftwares
    drop_table :contributionurls
  end

  def self.down
    drop_table :hyperlinks
  end
end
