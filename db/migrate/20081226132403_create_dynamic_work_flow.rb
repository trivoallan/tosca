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
class CreateDynamicWorkFlow < ActiveRecord::Migration
  class Statut < ActiveRecord::Base; end
  class Issuetype < ActiveRecord::Base; end

  def self.up
    create_table :workflows do |t|
      t.integer  :issuetype_id,                :null => false
      t.integer  :statut_id,                   :null => false
      t.string   :allowed_status_ids,          :null => false
    end
    add_index :workflows, :issuetype_id
    add_index(:workflows, [:issuetype_id, :statut_id], :unique => true)

    add_column :statuts, :active, :boolean, :null => false, :default => true
    statuts = Statut.all(:order => :id)
    statuts.each{|s| s.update_attribute(:active, (s.id <= 4))}

    # Clean up unused or messed up Issue types
    it = Issuetype.find_by_name('Monitorat')
    it.destroy if it
    it = Issuetype.find_by_name('Soutien utilisateur')
    it.destroy if it
    study = Issuetype.find_by_name('Étude')
    documentation = Issuetype.find_by_name('Documentation')
    if study and documentation
      Issue.record_timestamps = false
      Issue.all(:conditions => {:issuetype_id => study.id}).each do |i|
        i.update_attribute :issuetype_id, documentation.id
      end
      Issue.record_timestamps = true
    end
  end

  def self.down
    drop_table :workflows
    remove_column :statuts, :active
  end
end
