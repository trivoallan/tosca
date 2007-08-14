#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module FiltersHelper

  # Provides a select box to filter choice
  # select_filter(@logiciels, :logiciel)
  # select_filter(@types, :typedemande, :title => '» Type')
  def select_filter(list, property, options = {:title => '» '})
    out = ''
    field = "#{property}_id"
    # disabling auto submit, there is an observer in filter form
    options[:onchange] = ''
    filters = instance_variable_get(:@filters)
    default_value = (filters ? filters.send(field) : nil)
    out << select_onchange(list, default_value, 
                           "filters[#{field}]", options)
  end

  # TODO cas particulier pour select_filter(@severites, :severite)
  # les couleurs associée peuvent etre utilise dans le style du select
  def select_filter_severite
    "TODO"
  end

end
