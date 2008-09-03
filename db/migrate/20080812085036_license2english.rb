class License2english < ActiveRecord::Migration
  def self.up
    rename_column :licenses, :certifie_osi, :osi_certified
  end

  def self.down
    rename_column :licenses, :osi_certified, :certifie_osi
  end
end
