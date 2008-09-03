#
# Copyright (c) 2006-2008 Linagora
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
class CreateRulesCredits < ActiveRecord::Migration
  def self.up
    rename_table :time_tickets, :credits
    Contract.find(:all).each { |c|
      if c.rule_type == 'TimeTicket'
        c.update_attribute :rule_type, 'Rules::Credit'
      end
    }
  end

  def self.down
    rename_table :credits, :time_tickets
        Contract.find(:all).each { |c|
      if c.rule_type == 'Rules::Credit'
        c.update_attribute :rule_type, 'TimeTicket'
      end
    }

  end
end
