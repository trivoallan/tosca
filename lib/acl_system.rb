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
# This module is derived from the examples on Rails wiki.
# It's tosca implementation
#
# This module wires itself into the LoginSystem authorize? method.  You
# should use the normal:
#
#   before_filter :login_required
#
# or to leave some actions unprotected:
#
#   before_filter :login_required, :except => [ :list, :show ]
#
#
# See link:http://wiki.rubyonrails.com/rails/show/LoginGeneratorACLSystem
# for more info.
module ACLSystem

  include LoginSystem
  include PermissionCache

  protected

  # Authorizes the user for an action.
  # This works in conjunction with the LoginController.
  # The LoginController loads the User object.
  def authorize?(user)
    required_perm = "%s/%s" % [ params['controller'], params['action'] ]
    user.authorized?(required_perm)
  end





end
