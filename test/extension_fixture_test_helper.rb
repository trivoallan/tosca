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
module ExtensionFixtureTestHelper
  def self.included(base)
    unless base < ClassMethods
      base.send :include, InstanceMethods
      base.extend ClassMethods
      base.class_eval do
        class_inheritable_accessor :extension_fixture_table_names, :extension_fixture_path
        self.extension_fixture_table_names = []
        self.extension_fixture_path = ""
        alias_method_chain :load_fixtures, :extensions
      end
    end
  end

  module ClassMethods
    def extension_fixtures(*table_names)
      table_names = table_names.flatten.map { |n| n.to_s }
      self.extension_fixture_table_names = table_names
      require_fixture_classes(table_names)
      setup_fixture_accessors(table_names)
    end
  end

  module InstanceMethods
    def load_fixtures_with_extensions
      @loaded_fixtures = {}
      fixtures = Fixtures.create_fixtures(fixture_path, fixture_table_names, fixture_class_names),
      extension_fixtures = Fixtures.create_fixtures(extension_fixture_path, extension_fixture_table_names, fixture_class_names)
      [fixtures, extension_fixtures].each do |f|
        unless f.nil?
          if f.instance_of?(Fixtures)
            @loaded_fixtures[f.table_name] = f
          else
            f.each { |x| @loaded_fixtures[x.table_name] = x unless x.nil? }
          end
        end
      end
    end
  end
end