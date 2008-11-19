
if config.frameworks.include? :action_view
  require 'redbox_helper'
  ActionView::Base.send(:include, RedboxHelper)
end
