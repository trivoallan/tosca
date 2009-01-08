# ArActions
module ArActions

  def self.included(base)
    super(base)
    base.extend(ArClassMethods)
  end

  module ArClassMethods
    def inherited(subclass)
      super(subclass)
      subclass.send(:class_variable_set, :@@actions, [])
      subclass.send(:class_variable_set, :@@tabs, [])
    end

    # Used to define actions in extension.
    # They can be listed in index views after that.
    # See ods_export & index of Request for a real world example.
    def actions
      class_variable_get(:@@actions)
    end

    def tabs
      class_variable_get(:@@tabs)      
    end

    def register_action(action)
      actions << action unless actions.include? action
    end
    
    # Used to define tabs in extensions
    def register_tab(tab)
      tabs << tab unless tabs.include? tab
    end

  end
end
