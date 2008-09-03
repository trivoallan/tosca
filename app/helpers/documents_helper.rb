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
module DocumentsHelper

  # Link to a defined type of document
  # call it like : link_to_typedocument t 
  def link_to_typedocument(typedocument)
    return '-' unless typedocument
    size = typedocument.documents.size
    return nil if typedocument.documents.size == 0
    link_to "#{typedocument.name} (#{size})",  
      list_document_url(:id => typedocument.id) 
  end

end
