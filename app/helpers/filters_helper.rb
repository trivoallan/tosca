#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module FiltersHelper

  # Provides a select box to filter choice
  # select_filter(@logiciels, 'logiciel')
  # select_filter(@types, 'typedemande', :title => '» Type')
  def select_filter(list, property, options = {:title => "» #{property.capitalize}"})
    out = ''
    field = "#{property}_id"
    # it's so dirty. mais le bel appel à remote_function 
    # fait un bug sur le spinner :/
    # Celui qui arrive à nettoyer ca aura une biere free ;)
    options[:onchange] = "Element.show('spinner'); new Ajax.Updater('content', " + 
      "'/logiciels/update_list', {asynchronous:true, evalScripts:true, " + 
      "onSuccess:function(request){Element.hide('spinner')}}); return false;"
    out << select_onchange(list, 
                           session[:filters][field], "filters[#{field}]", 
                           options)
  end

  ############
  # Keep Dry #
  ############
  # One place if we want to change the label ;)
  def select_filter_severity
    select_filter(@severites, 'severite', :title => '» Sévérité')
  end
  def select_filter_typedemande
    select_filter(@types, 'typedemande', :title => '» Type')
  end
  def select_filter_engineer
    select_filter(@ingenieurs, 'ingenieur', :title => '» Responsable')
  end

  # TODO : MLO: wtf ? it's dirty
  def select_filter_date(options = {})
    out = ''
    out << '<br/>' unless options[:inline] == true
    out << date_select("filtres", "updated_on", :start_year => 2006,
                       :use_month_numbers => true, :include_blank => true, 
                       :order => [:day, :month, :year])
  end

  # Provides a filter box to 
  # text_filter('motcle', :title => 'Résumé')
  def text_filter(property, options = {})
    out = ''
    name = "filtres[#{property}]"
    # out << '<br/>' unless options[:inline] == true
    # out << text_field_tag(name, @session[:filtres][property], options)
    out << text_field('filters', property, :value => session[:filters][property], :size => 20 )
  end



end
