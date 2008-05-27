require_dependency "user"

module LoginSystem

  @@public_user = nil
  def self.public_user
    @@public_user ||= User.new(:role_id => 6)
  end

  protected

  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob"
  #  end
  # MLO : Not used for the moment. you can reactivate it
  # in 'login_required', just below
  def authorize?(user)
     true
  end

  # login_required filter. add
  #
  #   before_filter :login_required
  #
  # if the controller should be under any rights management.
  # for finer access control you can overwrite
  #
  #   def authorize?(user)
  #
  def login_required(redirect = true)

    return true if authorize?(LoginSystem::public_user)

    if session.data.has_key?(:user) and authorize?(session[:user])
      return true
    end

    # This method may be called by routes helper, when redirection
    # is not wished at all.
    if redirect
      store_location
      access_denied
    end

    return false
  end

  # overwrite if you want to have special behavior in case the user is not
  # authorized to access the current operation.
  # See http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
  def access_denied
    render :template => 'access/denied', :status => 401 # unauthorized
  end

  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end

end
