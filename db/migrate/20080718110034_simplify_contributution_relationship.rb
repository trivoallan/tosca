class SimplifyContribututionRelationship < ActiveRecord::Migration
  def self.up
    drop_table :contributions_versions
    add_column :contributions, :version_id, :integer
    add_index :contributions, :version_id
  end

  def self.down
    remove_column :contributions, :version_id
    create_table :contributions_versions, :id => false do |t|
      t.integer :contribution_id, :version_id
    end
    add_index :contributions_versions, :contribution_id
    add_index :contributions_versions, :version_id
  end
end
