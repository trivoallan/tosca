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
module PermissionCache
  # Used to be called with the routes overrides. See acl_system.rb for more deeper
  # explanation. It's used to allow public access.
  @@permissions_cache = nil
  def authorize_url?(options)
    # testing cache
    perm = "#{options[:controller]}/#{options[:action]}"
    user = @session_user
    role_id = (user ? user.role_id : 6) # 6 : public access

    return true if LoginSystem::public_user.authorized?(perm)
    return false unless user
    user.authorized?(perm)
  end
end
