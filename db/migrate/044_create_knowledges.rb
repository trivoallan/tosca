#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class CreateKnowledges < ActiveRecord::Migration

  class Role < ActiveRecord::Base
    has_and_belongs_to_many :permissions
  end
  class Permission < ActiveRecord::Base
    has_and_belongs_to_many :roles
  end

  @access = [ [ '^knowledges/', 'Full access' ] ]
  def self.up
    # TODO : Add a method to reduce this.
    # For now, it's copied from migration 003
    admin_id = Role.find(1)
    manager_id = Role.find(2)
    expert_id = Role.find(3)

    @roles = [ admin_id, manager_id, expert_id ]

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
