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
      result = user.authorized?(perm) unless result
      @@permissions_cache[role_id][perm] = result
    end
    @@permissions_cache[role_id][perm]
  end
end
