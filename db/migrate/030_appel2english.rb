class Appel2english < ActiveRecord::Migration
  class Appel < ActiveRecord::Base
  end

  def self.up
    rename_column :appels, :debut, :start
    rename_column :appels, :fin, :end

    rename_table :appels, :phonecalls
  end

  def self.down
    rename_table :phonecalls, :appels

    rename_column :appels, :start, :debut
    rename_column :appels, :end, :fin
  end
end
