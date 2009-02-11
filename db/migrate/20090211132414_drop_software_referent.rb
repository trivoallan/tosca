class DropSoftwareReferent < ActiveRecord::Migration

  def self.up
    remove_column :softwares, :referent
    rename_column :softwares, :resume, :summary
  end

  def self.down
    add_column :softwares, :referent, :string
    rename_column :softwares, :summary, :resume
  end

end
