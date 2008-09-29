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
module ExportHelper

  def issues_export_link
    export_link formatted_issues_export_path(:ods)
  end

  def phonecalls_export_images
    export_link formatted_phonecalls_export_path(:ods)
  end
  def users_export_link
    export_link formatted_users_export_path(:ods)
  end
  def comex_export_link
    export_link formatted_comex_export_path(:ods)
  end
  def contributions_export_link
    export_link formatted_contributions_export_path(:ods)
  end


  private
  # create a link with the images coresponding to the type mime of the export
  def export_link(url)
    link_to(_('Export in %s') % StaticImage::mime_ods, url)
  end
end

