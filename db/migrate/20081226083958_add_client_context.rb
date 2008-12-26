class AddClientContext < ActiveRecord::Migration
  def self.up
    change_column :clients, :description, :string
    change_column :clients, :address, :string
    rename_column :clients, :description, :context
  end

  def self.down
    rename_column :clients, :context, :description
    change_column :clients, :description, :text
    change_column :clients, :address, :text
  end

end
