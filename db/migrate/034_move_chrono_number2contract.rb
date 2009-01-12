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
class MoveChronoNumber2contract < ActiveRecord::Migration

  class Client < ActiveRecord::Base
    has_many :contracts
  end
  class Contract < ActiveRecord::Base
    belongs_to :client
  end

  def self.up
    add_column :contracts, :chrono, :integer, :default => 0, :null => false
    Client.all.each do |client|
      client.contracts.each {|c| c.update_attribute(:chrono, client.chrono)}
    end
    remove_column :clients, :chrono
  end

  def self.down
    add_column :clients, :chrono, :integer, :default => 0, :null => false
    Client.all.each do |client|
      client.contracts.each {|c| client.update_attribute(:chrono, c.chrono)}
    end
    remove_column :contracts, :chrono
  end

end
