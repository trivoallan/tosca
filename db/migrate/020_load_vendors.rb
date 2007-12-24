class LoadVendors < ActiveRecord::Migration
  class Distributeur < ActiveRecord::Base; end

  def self.up
    [ 'Canonical', 'Debian', 'Linagora', 'Mandriva', 'Red Hat, Inc',
      'SUSE LINUX Products GmbH, Nuernberg, Germany', 'Sun Corporation'
    ].each { |d| Distributeur.create(:nom => d) }
  end

  def self.down
    Distributeur.find(:all).each{ |d| d.destroy }
  end
end
