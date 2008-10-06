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
module FiltersHelper

  # Provides a select box to filter choice
  # select_filter(@softwares, :software)
  # select_filter(@types, :typeissue, :title => '» Type')
  def select_filter(list, property, options = {:title => '» '})
    out = ''
    field = "#{property}_id"
    # disabling auto submit, there is an observer in filter form
    options[:onchange] = ''
    filters = instance_variable_get(:@filters)
    default_value = (filters ? filters.send(field) : nil)
    out << select_onchange(list, default_value, 
                           "filters[#{field}]", options)
  end

  # TODO cas particulier pour select_filter(@severities, :severity)
  # les couleurs associée peuvent etre utilise dans le style du select
  def select_filter_severity
    "TODO"
  end

end
