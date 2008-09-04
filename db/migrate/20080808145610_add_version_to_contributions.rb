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
class AddVersionToContributions < ActiveRecord::Migration

  class Contribution < ActiveRecord::Base
    belongs_to :version
    belongs_to :logiciel

    belongs_to :affected_version, :class_name => "Version"
    belongs_to :fixed_version, :class_name => "Version"
  end

  class Logiciel < ActiveRecord::Base
    has_many :contributions
    has_many :versions, :order => "versions.name DESC"
  end

  class Version < ActiveRecord::Base
    belongs_to :logiciel

    has_many :contributions
  end

  def self.up
    add_column :contributions, :affected_version_id, :integer
    add_column :contributions, :fixed_version_id, :integer

    Contribution.all.each do |c|
      logiciel = c.logiciel

      #We create a version if there is none
      [:fixed_version, :affected_version].each do |type_version|
        type_version_value = c.read_attribute(type_version)
        type_version_id = logiciel.versions.find_by_name(type_version_value)
        if type_version_id.nil? && !type_version_value.blank?
          version = Version.new do |v|
            v.logiciel_id = logiciel.id
            case type_version_value
            when /\.[xX]/
              v.name = type_version_value.gsub(/\.[xX]/, "")
              v.generic = true
            when /^[xX]/
              v.name = ""
              v.generic = true
            else
              v.name = type_version_value
              v.generic = false
            end
          end
          version.save! unless Version.find(:first, :conditions => version.attributes)
          type_version_id = version.id
        end
        c.write_attribute(type_version, type_version_id)
      end
      c.save
    end

    remove_column :contributions, :affected_version
    remove_column :contributions, :fixed_version
    remove_column :contributions, :version_id
    add_index :contributions, :fixed_version_id
    add_index :contributions, :affected_version_id
  end

  def self.down
    add_column :contributions, :affected_version, :integer
    add_column :contributions, :fixed_version, :integer
    add_column :contributions, :version_id, :integer

    remove_column :contributions, :affected_version_id, :fixed_version_id
  end
end
