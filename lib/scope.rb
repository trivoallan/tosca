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
module Scope

  private
  # There is a global scope, on all finders, in order to
  # preserve each user in his particular space.
  # This method has a 'handmade' scope, really faster and with no cost
  # of safety. It was made in order to avoid 15 yields.
  def define_scope(user)
    set_scopes user
    begin
      yield
    ensure
      remove_scope user
    end
  end


  # Beware that this method is linked with remove_scope
  # It's used to set up models for a new request
  def set_scopes(user)
    # defined locally since this file is loaded by application controller
    # it reduces dramatically loading time
    @@scope_client ||= @@models.select(&:scope_client?)
    @@scope_contract ||= @@models.select(&:scope_contract?)

    if !user.nil?
      # You can NOT change this condition without looking at remove_scope
      if ((user.engineer? and user.restricted?) || user.recipient?)
        contract_ids = user.contract_ids
        client_ids = user.client_ids
        if contract_ids.empty?
          contract_ids = [ 0 ]
          client_ids = [ user.client_id ] if user.recipient?
        end
        @@scope_contract.each {|m| m.set_scope(contract_ids) }
        @@scope_client.each {|m| m.set_scope(client_ids) }
        # Forbid access to private comments for recipients. It's just paranoia.
        Comment.set_private_scope if user.recipient?
      end
    else
      # Forbid access to issue if we are not connected. It's just a paranoia.
      Issue.set_scope([0])
      Software.set_public_scope
    end
  end

  # Beware that this method is linked with set_scope
  # It's used to clean up models after the request
  def remove_scopes(user)
    if !user.nil?
      # You can NOT change this condition without looking at set_scope
      if ((user.engineer? and user.restricted?) || user.recipient?)
        @@scope_client.each(&:remove_scope)
        @@scope_contract.each(&:remove_scope)
        Comment.remove_scope if user.recipient?
      end
    else
      Issue.remove_scope
      Software.remove_scope
    end
  end


  #We load all the models
  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
  @@models = Object.subclasses_of(ActiveRecord::Base)

end
