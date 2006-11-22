# See <a href="http://wiki.rubyonrails.com/rails/show/LoginGeneratorACLSystem">http://wiki.rubyonrails.com/rails/show/LoginGeneratorACLSystem</a>

module ACLSystem

  include LoginSystem

  # This module wires itself into the LoginSystem authorize? method.  You
  # should use the normal:
  #
  #   before_filter :login_required
  #
  # or to leave some actions unprotected:
  #
  #   before_filter :login_required, :except => [ :list, :show ]
  #

  protected

  # Authorizes the user for an action.
  # This works in conjunction with the LoginController.
  # The LoginController loads the User object.
  def authorize?(user)
    required_perm = "%s/%s" % [ @params['controller'], @params['action'] ]
    if user.authorized? required_perm
      return true
    end
    return false
  end

end
