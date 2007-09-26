class DeleteUrlsreversementAndUrllogiciels < ActiveRecord::Migration
  def self.up
    drop_table :urlreversements
    drop_table :urllogiciels
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
