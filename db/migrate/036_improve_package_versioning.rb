class ImprovePackageVersioning < ActiveRecord::Migration
  class Paquet < ActiveRecord::Base
    belongs_to :logiciel
    belongs_to :contract, :counter_cache => true
    belongs_to :mainteneur

    has_many :changelogs, :dependent => :destroy
    has_many :binaires, :dependent => :destroy, :include => :version
    has_and_belongs_to_many :contributions
  end
  
  def self.up
    change_column :paquets, :version, :string,  :limit => 60, :default => "x",  :null => false
    change_column :paquets, :release, :string,  :limit => 60, :default => nil, :null => true
    Paquet.find(:all).each do |p|
      p.update_attribute :release, nil if p.release == ''
    end
  end

  # no need for this one
  def self.down
  end
end
