class LoadAdminAccount < ActiveRecord::Migration
  class Identifiant < ActiveRecord::Base
    has_one :ingenieur, :dependent => :destroy
  end
  class Ingenieur < ActiveRecord::Base; end

  def self.up
    # Admin account
    admin_id, manager_id, expert_id, customer_id, viewer_id = 1,2,3,4,5
    Identifiant.create(:nom => 'admin', :role_id => admin_id, :password =>
                       Digest::SHA1.hexdigest("linagora--#{'admin'}--"))
    Ingenieur.create(:identifiant_id => 1)
  end

  def self.down
    Identifiant.find(1).destroy
  end
end
