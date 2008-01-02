#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
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

  protected

  # Authorizes the user for an action.
  # This works in conjunction with the LoginController.
  # The LoginController loads the User object.
  def authorize?(user)
    required_perm = "%s/%s" % [ params['controller'], params['action'] ]
    user.authorized?(required_perm)
  end



end
