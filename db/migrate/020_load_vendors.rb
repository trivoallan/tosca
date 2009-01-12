class LoadVendors < ActiveRecord::Migration
  class Distributeur < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Vendors
    return unless Distributeur.count == 0

    # Sample ones
    [ 'Canonical', 'Debian', 'Linagora', 'Mandriva', 'Red Hat, Inc',
      'SUSE LINUX Products GmbH, Nuernberg, Germany', 'Sun Corporation'
    ].each { |d| Distributeur.create(:nom => d) }
  end

  def self.down
    Distributeur.all.each{ |d| d.destroy }
  end
end
