class Appel2english < ActiveRecord::Migration
  class Appel < ActiveRecord::Base
  end
  class Permission < ActiveRecord::Base
  end

  def self.up
    rename_column :appels, :debut, :start
    rename_column :appels, :fin, :end

    rename_table :appels, :phonecalls

    Permission.find_all_by_name('^appels/(?!destroy)').each { |p|
      p.update_attribute :name, '^phonecalls/(?!destroy)'
    }
  end

  def self.down
    rename_table :phonecalls, :appels

    rename_column :appels, :start, :debut
    rename_column :appels, :end, :fin

    Permission.find_all_by_name('^phonecalls/(?!destroy)').each { |p|
      p.update :name, '^appels/(?!destroy)'
    }

  end
end
