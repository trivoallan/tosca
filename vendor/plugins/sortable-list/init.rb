if config.frameworks.include? :action_view
  require 'sortable_list_helper'
  ActionView::Base.send :include, SortableListHelper
end
