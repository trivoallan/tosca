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
class Contribution2english < ActiveRecord::Migration
  def self.up
    rename_column :contributions, :reverse_le, :contributed_on
    rename_column :contributions, :cloture_le, :closed_on
    rename_column :contributions, :synthese, :synthesis
    # this field was not used
    update("UPDATE contributions SET description = description_fonctionnelle")
    remove_column :contributions, :description_fonctionnelle
  end

  def self.down
    rename_column :contributions, :contributed_on, :reverse_le
    rename_column :contributions, :closed_on, :cloture_le
    rename_column :contributions, :synthesis, :synthese
    add_column :contributions, :description_fontionnelle, :text
  end
end
