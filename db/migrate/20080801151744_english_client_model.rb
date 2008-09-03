class EnglishClientModel < ActiveRecord::Migration
  def self.up
    rename_column :clients, :adresse, :address
    rename_column :clients, :code_acces, :access_code
  end

  def self.down
    rename_column :clients, :address, :adresse
    rename_column :clients, :access_code, :code_acces
  end
end
