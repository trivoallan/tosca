# This module contains all the stuff related to forms.
module FormsHelper

  PROMPT_SELECT = { :prompt => '» ' }

  ### FORMULAIRES ##################################################

  # Collection doit contenir des objects qui ont un 'id' et un 'name'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # L'option :size permet une mise en colonne
  # Ex : hbtm_check_box( @logiciel.competences, @competences, 'competence_ids')
  def hbtm_check_box( objectcollection, collection, name , options={})
    return '' if collection.nil? || collection.empty?
    objectcollection = objectcollection.collect { |c| [ c.name, c.id ] }
    out = '<table class="list"><tr>' and count = 1
    options_size = options[:size]
    length = collection.size
    name_w3c = name.gsub(/[^a-z1-9]+/i, '_')
    for donnee in collection
      out << "<td class=\"#{cycle('odd', 'even')}\">"
      out <<  "<label for=\"#{name_w3c}_#{donnee.last}\">"
      out <<   "<input id=\"#{name_w3c}_#{donnee.last}\" type=\"checkbox\" "
      out <<      "name=\"#{name}[]\" value=\"#{donnee.last}\" "
      out <<      'checked="checked" ' if objectcollection.include? donnee
      out <<   "/>#{donnee.first}"
      out <<  "</label>"
      out << "</td>"
      if options_size
        out << "</tr><tr>" if (count % options_size == 0) and length > count
        count += 1
      end
    end
    out << '</tr></table>'
    out << "<input id=\"#{name_w3c}_\" type=\"hidden\" name=\"#{name}[]\" value=\"\" >"
  end

  # Collection have to contain object which respond to 'id' and 'name'
  # Object & Param allow to keep n' display the selected one
  # In the options, you have :
  #   * :size => Number of columns before an end of line (<br />)
  # Ex : hm_radio_button( 'user', 'role_id', @roles, :size => 3)
  def hm_radio_button( object, param, collection, options = {})
    out = ''
    return out if collection.nil?
    options_size = options[:size]
    count = 1
    for data in collection
      out << radio_button(object, param, data.last)
      out << "<label for=\"#{object}_#{param}_#{data.last}\">#{data.first}</label> "
      if options_size
        out << '<br />' if (count % options_size == 0)
        count += 1
      end
    end
    out
  end

  # select_onchange(@clients, @current_client, 'client')
  # options
  # :width limit size of displayed characters
  # :title 1st element of the list. Default is the selector '» '
  # :first_value, first_line :
  #   1st content line to display, after the title.
  #    It <strong>must</strong> respond_to? :name & :id
  # :onchange javascript's action
  # :size height of the select
  def select_onchange(list, default, name, options = {})
    title = [[options[:title] || '» ', '' ]]
    options[:onchange] ||= 'this.form.submit();'
    options[:name] ||= name

    if options.has_key?(:first_value)
      options[:first_name] ||= options[:first_value].name
      title.push([options[:first_name] , options[:first_value].id ])
    end
    list = title.concat(list || [])

    default_value = (default.is_a?(Numeric) ? default : 0)
    select = options_for_select(list, default_value)
    content_tag :select, select, options
  end

  def select_empty(object, method, choices, options = {}, html_options = {})
    title = [[ '» ', '' ]]
    select(object, method, title.concat(choices), options, html_options)
  end

  # Fields est un tableau du formulaire, en 2 colonnes
  # mutualisé pour le formulaire et l'affichage
  # Les éléments doivent être affichable par to_s
  # si l'une des colonne est à nil, la ligne est fusionnée
  # /!\ Do not call it anymore /!\
  def show_table_form(fields, options = {})
    fields.compact!
    result = ''
    style = "class='#{options[:class]}'" if options.has_key? :class
    result << "<table #{style}>"
    fields.each { |f|
      title, field = f.first, f.last
      unless title.nil? and field.nil?
        result << '<tr>'
        if field.nil?
          result << '<td colspan="2">' << title << '</td>'
        elsif title.nil?
          result << '<td colspan="2">' << field << '</td>'
        else
          result << "<td>#{title}</td>"
          result << "<td>#{field}</td>"
        end
        result << '</tr>'
      end
    }
    result << '</table>'
  end

  # Display a quick form field to go to a ticket
  # TODO : use yield to include what we want in the form
  # Call it like :
  #  if session[:user] && session[:user].authorized?('demandes/index')
  #    out << form_tag(demandes_path)
  #    out <<  search_demande_field
  #    out << end_form_tag
  #  end
  def search_demande_field(options = {})
    text_field('numero', '', 'size' => 3)
  end
  alias_method :search_demande, :search_demande_field



  # write the label with the field.
  # heavily used in account with show_table_form
  # call it like this :
  # lstm_text_field(_('User|phone'), 'user', 'phone')
  def lstm_text_field(label, mmodel, field, options = {})
    [ "<label for=\"#{mmodel}_#{field}\">#{label}</label>",
      text_field(mmodel, field, options) ]
  end

  def lstm_password_field(label, model, field,
                          options = {:size => 16, :value => ''})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      password_field(model, field, options) ]
  end

  def lstm_text_area(label, model, field, options = {})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      text_area(model, field, options) ]
  end

  # Used for hiding field which will be displaye by ajax_*
  # call it like this :
  #   lstm_ajax_field('Bénéficiaire', :appel, :beneficiaires),
  def lstm_ajax_field(label, model, field)
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      "<div id=\"#{field}\"></div>" ]
  end

  # put a select field in a lazy way
  # call it like this :
  #  lstm_select_field('Contract', :appel, :contract, @contracts, :spinner => true)
  # options :
  #  * spinner : put the spinner for ajax stuff
  def lstm_select_field(label, model, field, collection, options = {})
    result = [ "<label for=\"#{model}_#{field}\">#{label}</label>",
               collection_select(model, field.to_s + '_id', collection,
                                 :last, :first, PROMPT_SELECT)  ]
    result.last << ' ' + StaticImage::spinner if options.has_key? :spinner
    result
  end

  def lstm_datetime_field(label, model, field, options={})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      datetime_select(model, field) ]
  end

  def lstm_hline
    [ '<hr/>', nil ]
  end

  def auto_complete(object, method, tag_options = {}, completion_options = {})
    text_field_with_auto_complete(object, method, tag_options)
  end

  def auto_complete_list(object, method, objectcollection, name, tag_options = {}, completion_options = {})
    @object = object
    @method = method
    @name =  name
    @button = delete_button "tr_#{@object}_#{@method}_#{@value}"
    out = "<table>"
    out << "<tr><td>"
    tag_options[:value]=""
    out << text_field_with_auto_complete(object, method, tag_options, completion_options)
    out << "</td><td>"
    out << "<table>"
    objectcollection.each do |c|
      @content = c.name
      @value = c.id
      @button = delete_button "tr_#{@object}_#{@method}_#{@value}"
      out << "#{render :partial => 'applications/auto_complete_insert'}"
    end
    @content = ""
    @value = ""
    @button = ""
    out << "#{render :partial => 'applications/auto_complete_insert'}"
    out << "</table>"
    out << "</td></tr>"
    out << "</table>"
  end

  def auto_complete_choice( object, method, collection, name , options={})
    return '' if collection.nil? || collection.empty?
    @object = object
    @method = method
    @name = name
    content_tag(:ul, collection.map do |c|
      @value = c.id
      @content = c.name
      @button = delete_button "tr_#{@object}_#{@method}_#{@value}"
      @new_record = true
      out = ""
      out << "<div "
      out <<   "name=\"#{name}\" value=\"#{c.id}\">#{c}"
      out << "</div>"
      out = link_to_function(out, :class => "no_hover") { |page| 
        page.insert_html :before, "tr_#{@object}_#{@method}_", :partial => 'applications/auto_complete_insert'
        page.visual_effect(:appear, "tr_#{@object}_#{@method}_#{@value}")
        page.delay(0.001) { page["#{object}_#{method}"].value = "" }
      }
      content_tag(:li, out) 
    end )
  end

  def delete_button(id)
    link_to_function(StaticImage::delete, :class => :no_hover ) { |page|
      page.visual_effect :fade, id.to_s, :duration => 0.5
      #We wait for the nice effect to finish
      page.delay(0.5) { page.remove id }
    }
  end

end
