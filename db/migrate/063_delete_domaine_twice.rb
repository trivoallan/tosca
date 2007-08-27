class DeleteDomaineTwice < ActiveRecord::Migration
  def self.up
    remove_column :beneficiaires, :domaine
    remove_column :ingenieurs, :domaine
  end

  def self.down
    add_column :beneficiaires, :domaine, :text
    add_column :ingenieurs, :domaine, :text
  end
end
