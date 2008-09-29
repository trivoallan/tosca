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
module Scope

  private
  # There is a global scope, on all finders, in order to
  # preserve each user in his particular space.
  # TODO : scope contract only ?? it seems coherent...
  # This method has a 'handmade' scope, really faster and with no cost
  # of safety. It was made in order to avoid 15 yields.
  def define_scope(user, is_connected)
    # defined locally since this file is loaded by application controller
    # it reduces dramatically loading time
    @@scope_client ||= [ Client, Document ]
    @@scope_contract ||= [ Release, Contract, Issue, Phonecall, Tag ]
    if is_connected
      recipient, ingenieur = user.recipient, user.ingenieur
      apply = ((ingenieur and user.restricted?) || recipient)
      if apply
        contract_ids = user.contract_ids
        client_ids = user.client_ids
        if contract_ids.empty?
          contract_ids = [ 0 ]
          client_ids = [ recipient.client_id ] if recipient
        end
        @@scope_contract.each {|m| m.set_scope(contract_ids) }
        @@scope_client.each {|m| m.set_scope(client_ids) }
      end
    else
      # Forbid access to issue if we are not connected. It's just a paranoia.
      Issue.set_scope([0])
    end
    begin
      yield
    ensure
      if is_connected
        if apply
          @@scope_client.each { |m| m.remove_scope }
          @@scope_contract.each { |m| m.remove_scope }
        end
      else
        Issue.remove_scope
      end
    end
  end

end
