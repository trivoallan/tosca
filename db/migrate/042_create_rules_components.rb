class CreateRulesComponents < ActiveRecord::Migration
  def self.up
    rename_table :ossas, :components
  end

  def self.down
    rename_table :components, :ossas
  end
end
