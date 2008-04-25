class AddFixedVersionForContributions < ActiveRecord::Migration

  def self.up
    
    # on ajoute le champ fixed_version afin de stocker la version dans laquelle
    # la contribution a été prise en compte
    add_column :contributions, "fixed_version", :string

    # renomme le champ version en affected_version
    rename_column :contributions, "version", "affected_version"

  end

  def self.down
    
    rename_column :contributions, "affected_version", "version"

    remove_column :contributions, "fixed_version"

  end

end
