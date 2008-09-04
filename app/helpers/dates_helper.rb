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
module DatesHelper
  
  def pretty_date(date)
    day = sprintf("%02d", date.day)
    month = _(date.strftime("%b"))
    
    result = ""
    result << '<div class="datestamp">'
    result << '<div>'
    result << "<span class=\"cal1 cal1x\">#{month}</span>"
    result << "<span class=\"cal2\">#{day}</span>"
    result << "<span class=\"cal3\">#{date.year}</span>"
    result << '</div>'
    result << '</div>'
  end
  
  def complete_date(date)
     result = _(date.strftime("%A"))            #day of the week : Monday
     result << " "
     result << date.strftime("%d")              #day of the month : 10
     result << " "
     result << _(date.strftime("%B"))           #month : December
     result << " "
     result << date.strftime("%Y")              #Year : 2007
  end
  
end
