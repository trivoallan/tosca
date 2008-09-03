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
module PermissionCache
  # Used to be called with the routes overrides. See acl_system.rb for more deeper
  # explanation. It's used to allow public access.
  @@permissions_cache = nil
  def authorize_url?(options)
    # first call
    @@permissions_cache = Array.new(7, Hash.new) if @@permissions_cache.nil?

    # testing cache
    perm = "#{options[:controller]}/#{options[:action]}"
    user = session[:user]
    role_id = (user ? user.role_id : 6) # 6 : public access

    if !@@permissions_cache[role_id].has_key?(perm)
      result = LoginSystem::public_user.authorized?(perm)
      result = user.authorized?(perm) if !result && user
      @@permissions_cache[role_id][perm] = result
    end
    @@permissions_cache[role_id][perm]
  end
end
