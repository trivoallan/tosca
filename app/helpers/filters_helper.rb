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
    out << select_onchange(list, session[:filters][field], 
                           "filters[#{field}]", options)
  end

  # TODO cas particulier pour select_filter(@severites, :severite)
  # les couleurs associée peuvent etre utilise dans le style du select
  def select_filter_severite
    "TODO"
  end

  # TODO : MLO: wtf ? it's dirty
  # and even with a fixed year in it
  def select_filter_date(options = {})
    out = ''
    out << '<br/>' unless options[:inline] == true
    out << date_select("filtres", "updated_on", :start_year => 2006,
                       :use_month_numbers => true, :include_blank => true, 
                       :order => [:day, :month, :year])
  end

end
