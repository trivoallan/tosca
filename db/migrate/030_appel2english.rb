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
class Appel2english < ActiveRecord::Migration
  class Appel < ActiveRecord::Base
  end
  class Permission < ActiveRecord::Base
  end

  def self.up
    rename_column :appels, :debut, :start
    rename_column :appels, :fin, :end

    rename_table :appels, :phonecalls

    Permission.find_all_by_name('^appels/(?!destroy)').each { |p|
      p.update_attribute :name, '^phonecalls/(?!destroy)'
    }
  end

  def self.down
    rename_table :phonecalls, :appels

    rename_column :appels, :start, :debut
    rename_column :appels, :end, :fin

    Permission.find_all_by_name('^phonecalls/(?!destroy)').each { |p|
      p.update :name, '^appels/(?!destroy)'
    }

  end
end
