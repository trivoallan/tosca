# Override, in order to gracefully migrate into Rails 2.1 & Edge Gettext
module ActionView
  class Base
    delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
  end
end
