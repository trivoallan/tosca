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
class MoveMailinglist2contract < ActiveRecord::Migration
  class Contract < ActiveRecord::Base
    belongs_to :client
  end
  class Client < ActiveRecord::Base
    has_many :contracts
  end

  def self.up
    add_column :contracts, :mailinglist, :string,
      :limit => 50, :null => false, :default => ''
    Client.all.each do |cl|
      ml = cl.mailingliste
      cl.contracts.each { |co| co.update_attribute :mailinglist, ml }
    end
    remove_column :clients, :mailingliste
  end

  def self.down
    add_column :clients, :mailingliste, :string, :limit => 50, :null => false
    Contract.all.each do |co|
      co.client.update_attribute :mailingliste, co.mailinglist
    end
    remove_column :contracts, :mailinglist
  end
end
