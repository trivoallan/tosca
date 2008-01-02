class ImprovePackageVersioning < ActiveRecord::Migration
  def self.up
    change_column :paquets, :version, :string,  :limit => 60, :default => "x",   :null => false
    change_column :paquets, :release, :string,  :limit => 60, :default => nil, :null => true
    Paquet.find(:all).each do |p|
      p.update_attribute :release, nil if p.release == ''
    end
  end

  # no need for this one
  def self.down
  end
end
