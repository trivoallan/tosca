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
    end

    # Used to define actions in extension.
    # They can be listed in index views after that.
    # See ods_export & index of Request for a real world example.
    def actions
      class_variable_get(:@@actions)
    end

    #
    def register_action(action)
      actions << action unless actions.include? action
    end
  end
end
