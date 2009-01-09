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
module HyperlinksHelper
  # Call it like this :
  #   link_to_new_hyperlink("contribution", @contribution.id)
  def link_to_new_hyperlink(model, model_id)
    return '-' if not model_id and not model
    options = { :model_id => model_id, :model_type => model.to_s }
    link_to(image_create('a hyperlink'), new_hyperlink_path(options))
  end
end
