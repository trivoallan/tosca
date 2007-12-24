class LoadPackageSystems < ActiveRecord::Migration
  class Conteneur < ActiveRecord::Base; end

  def self.up
    # Known package system
    %w(rpm deb tarball nosrc pkg).each { |c|
      Conteneur.create(:nom => c)
    }
  end

  def self.down
    Conteneur.find(:all).each{ |c| c.destroy }
  end
end
