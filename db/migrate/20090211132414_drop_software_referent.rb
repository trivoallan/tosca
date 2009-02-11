class DropSoftwareReferent < ActiveRecord::Migration

  def self.up
    remove_column :softwares, :referent
  end

  def self.down
    add_column :softwares, :referent, :string
  end

end
