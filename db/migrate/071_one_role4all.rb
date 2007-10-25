class OneRole4all < ActiveRecord::Migration
  def self.up
    add_column :identifiants, :role_id, :integer, :null => false, :default => 0
    update("UPDATE identifiants i SET i.role_id = " <<
           "(SELECT ir.role_id FROM identifiants_roles ir INNER JOIN roles r" <<
           " ON r.id=ir.role_id WHERE ir.identifiant_id=i.id)")
#     inactive clients were made with no role, initially.
    update("UPDATE identifiants i SET i.role_id = 2, i.inactive = 1 " <<
           "WHERE i.role_id IS NULL OR i.role_id = 0")
    drop_table :identifiants_roles
  end

  def self.down
    remove_column :identifiants, :role_id
  end

end
