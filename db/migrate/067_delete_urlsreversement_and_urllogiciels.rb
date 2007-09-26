class DeleteUrlsreversementAndUrllogiciels < ActiveRecord::Migration
  def self.up
    rename_table :urlreversements, :old_urlreversements
    rename_table :urllogiciels, :old_urllogiciels
  end

  def self.down
    rename_table :old_urllogiciels, :urllogiciels
    rename_table :old_urlreversements, :urlreversements
  end
end
