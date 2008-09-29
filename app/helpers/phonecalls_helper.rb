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
module PhonecallsHelper

  # call it like : link_to_call call
  def link_to_call(phonecall)
    link_to StaticImage::view, phonecall_url(:id => phonecall.id)
  end

  # call it like : link_to_add_call issue.id
  def link_to_add_call(issue_id)
    return '-' unless issue_id
    link_to _('Add a phone call'), new_phonecall_url(:id => issue_id)
  end
end
