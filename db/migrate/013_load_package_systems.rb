class LoadPackageSystems < ActiveRecord::Migration
  class Conteneur < ActiveRecord::Base; end

  def self.up
    # Do not erase existing package system
    return unless Conteneur.count == 0

    # Known package system
    %w(rpm deb tarball nosrc pkg).each { |c|
      Conteneur.create(:nom => c)
    }
  end

  def self.down
    Conteneur.find(:all).each{ |c| c.destroy }
  end
end
