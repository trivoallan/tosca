class AddDateDelivery4document < ActiveRecord::Migration
  def self.up
    add_column :documents, :date_delivery,  :timestamp
    add_column :document_versions, :date_delivery, :timestamp
  end

  def self.down
    remove_column :documents, :date_delivery
    remove_column :document_versions, :date_delivery
  end
end
