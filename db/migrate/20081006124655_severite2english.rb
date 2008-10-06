class Severite2english < ActiveRecord::Migration
  def self.up
    rename_table :severites, :severities
    rename_column :comments, :severite_id, :severity_id
    rename_column :commitments, :severite_id, :severity_id
    rename_column :issues, :severite_id, :severity_id
  end

  def self.down
    rename_table :severities, :severites
    rename_column :comments, :severity_id, :severite_id
    rename_column :commitments, :severity_id, :severite_id
    rename_column :issues, :severity_id, :severite_id
  end
end
