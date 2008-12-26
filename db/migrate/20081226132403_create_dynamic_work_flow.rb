class CreateDynamicWorkFlow < ActiveRecord::Migration
  class Statut < ActiveRecord::Base; end
  class Issuetype < ActiveRecord::Base; end

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

    # Clean up unused or messed up^Issue types
    it = Issuetype.find_by_name('Monitorat')
    it.destroy if it
    it = Issuetype.find_by_name('Soutien utilisateur')
    it.destroy if it
    study = Issuetype.find_by_name('Étude')
    documentation = Issuetype.find_by_name('Documentation')
    if study and documentation
      Issue.record_timestamp = false
      Issue.all(:conditions => {:issuetype_id => study.id}).each do |i|
        i.update_attribute :issuetype_id, documentation.id
      end
      Issue.record_timestamp = true
    end
  end

  def self.down
    drop_table :workflows
    remove_column :statuts, :active
  end
end
