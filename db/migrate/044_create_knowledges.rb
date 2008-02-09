class CreateKnowledges < ActiveRecord::Migration

  # TODO : Add a method to reduce this.
  # For now, it's copied from migration 003
  # accounts id
  admin_id = Role.find(1)
  manager_id = Role.find(2)
  expert_id = Role.find(3)

  @roles = [ admin_id, manager_id, expert_id ]
  @access = [ [ '^knowledges/', 'Full access' ] ]

  def self.up
    create_table :knowledges do |t|
      t.integer :competence_id, :null => true
      t.integer :logiciel_id, :null => true
      t.integer :ingenieur_id, :null => true
      # 0 : noob, 5 : commit access
      t.integer :level, :null => false, :limit => 6
    end

    add_index :knowledges, :competence_id
    add_index :knowledges, :ingenieur_id
    add_index :knowledges, :logiciel_id


    # Permission distribution
    add_permission = Proc.new do |roles, access|
      access.each { |a|
        p = Permission.create(:name => a.first, :info => a.last)
        p.roles = roles
        p.save
      }
    end

    add_permission.call(@roles, @access)


    drop_table :competences_ingenieurs
  end

  def self.down
    drop_table :knowledges

    create_table "competences_ingenieurs", :id => false, :force => true do |t|
      t.column "ingenieur_id",  :integer, :default => 0, :null => false
      t.column "competence_id", :integer, :default => 0, :null => false
      t.column "niveau",        :integer
    end

    add_index "competences_ingenieurs", ["ingenieur_id"], :name => "competences_ingenieurs_ingenieur_id_index"
    add_index "competences_ingenieurs", ["competence_id"], :name => "competences_ingenieurs_competence_id_index"

    Permission.find_all_by_name(@access.first.first).each { |p|
      p.destroy
    }
  end
end
