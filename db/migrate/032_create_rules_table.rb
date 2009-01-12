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
class CreateRulesTable < ActiveRecord::Migration
  class Contract < ActiveRecord::Base; end

  def self.up
    create_table :time_tickets do |t|
      t.column :name,   :string, :null => false
      # maximum number of time-tickets
      t.column :max,    :integer, :default => 20
      # time of a ticket
      t.column :time,   :float, :default => 0.25
    end

    create_table :ossas do |t|
      t.column :name,           :string, :null => false
      # maximum number of components. -1 => all components of the earth
      t.column :max,            :integer, :default => -1
    end

    Contract.all.each do |c|
      if c.support?
        c[:rule_type] = 'Rules::Credit'
      else
        c[:rule_type] = "Ossa"
      end
      c[:rule_id] = 1
      c.name = '' # reset of their name, more easier since the state of the past
      c.save
    end
    remove_column :contracts, :support
    remove_column :contracts, :socle
  end

  def self.down
    drop_table :ossas
    drop_table :time_tickets
    add_column :contracts, :support, :boolean, :default => false, :null => false
    add_column :contracts, :socle, :boolean, :default => false, :null => false
  end
end
