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
class AddFixedVersionForContributions < ActiveRecord::Migration

  def self.up
    
    # on ajoute le champ fixed_version afin de stocker la version dans laquelle
    # la contribution a été prise en compte
    add_column :contributions, "fixed_version", :string

    # renomme le champ version en affected_version
    rename_column :contributions, "version", "affected_version"

  end

  def self.down
    
    rename_column :contributions, "affected_version", "version"

    remove_column :contributions, "fixed_version"

  end

end
