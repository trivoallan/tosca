class CreateDynamicWorkFlow < ActiveRecord::Migration
  class Statut < ActiveRecord::Base; end

  def self.up
    create_table :workflows do |t|
      t.integer  :issuetype_id,                 :null => false
      t.integer  :statut_id,                   :null => false
      t.string   :allowed_status_ids,          :null => false
    end
    add_index :workflows, :issuetype_id
    add_index(:workflows, [:issuetype_id, :statut_id], :unique => true)

    add_column :statuts, :active, :boolean, :null => false, :default => true
    statuts = Statut.all(:order => id)
    statuts.each{|s| s.update_attribute(:active, (s.id <= 4))}
  end

  def self.down
    drop_table :workflows
    remove_column :statuts, :active
  end
end
