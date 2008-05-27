class AccessController < ApplicationController

  # No authentication is required for access denied page
  skip_before_filter :login_required

  def denied
  end

end
