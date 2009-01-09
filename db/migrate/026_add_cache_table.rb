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
class AddCacheTable < ActiveRecord::Migration
  def self.up
    create_table :elapseds do |t|
      t.integer :demande_id, :null => false
      t.integer :taken_into_account
      t.integer :workaround
      t.integer :correction
      t.integer :until_now
    end
    add_index :elapseds, :demande_id, :unique => true

    add_column :commentaires, :elapsed, :integer, :null => false, :default => 0
  end

  def self.down
    drop_table :elapseds
    remove_column :commentaires, :elapsed
  end
end
