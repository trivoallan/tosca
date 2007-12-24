class RemoveDescriptionFromRequest < ActiveRecord::Migration
  def self.up
    remove_column :demandes, :description
    change_column :demandes, :resume, :string, :limit => 70
  end

  def self.down
    add_column :demandes, :description, :text
    change_column :demandes, :resume, :string
  end
end
